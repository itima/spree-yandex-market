# -*- coding: utf-8 -*-
require 'nokogiri'

module Export
  class YandexMarketExporter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::SanitizeHelper

    attr_accessor :host, :currencies

    def helper
      @helper ||= ApplicationController.helpers
    end
    
    def export
      @config = SpreeYandexMarket::Config
      @host = @config[:url].sub(%r[^http://],'').sub(%r[/$], '')

      @currencies = @config[:currency].split(';').map{ |x| x.split(':') }
      @currencies.first[1] = 1
      
      @preferred_category = Spree::Taxon.find_by_name(@config[:category])
      unless @preferred_category && @preferred_category.export_to_yandex_market
        Rails.logger.error("[ yandex_market ] ERROR WHEN EXPORT")
        Rails.logger.error("[ yandex_market ] #{@config.parameters.to_yaml}") if @config.parameters
        raise "Preferred category <#{@preferred_category.name}> not included to export"
      end

      @categories = @preferred_category.self_and_descendants\
                    .where(:export_to_yandex_market => true)

      @categories_ids = @categories.collect { |x| x.id }
      
      Nokogiri::XML::Builder.new(:encoding => 'utf-8') do |xml|
        xml.doc.create_internal_subset('yml_catalog', nil, 'shops.dtd')

        xml.yml_catalog(:date => Time.now.to_s(:ym)) {
          xml.shop { # описание магазина
            xml.name      @config[:short_name]
            xml.company   @config[:full_name]
            xml.url       @config[:url]
            xml.platform  @config[:platform]
            xml.version   @config[:version]
            xml.agency    @config[:agency]
            xml.email     @config[:email]
            
            xml.currencies { # описание используемых валют в магазине
              @currencies && @currencies.each do |curr|
                opt = { :id => curr.first, :rate => curr[1] }
                opt.merge!({ :plus => curr[2] }) if curr[2] && ["CBRF","NBU","NBK","CB"].include?(curr[1])
                xml.currency(opt)
              end
            }        
            
            xml.categories { # категории товара
              @categories_ids && @categories.each do |cat|
                @cat_opt = { :id => cat.id }
                @cat_opt.merge!({ :parentId => cat.parent_id }) unless cat.parent_id.blank?
                xml.category(@cat_opt){ xml  << cat.name }
              end
            }

            xml.offers { # список товаров
              products = Spree::Product.in_taxon(@preferred_category).active.master_price_gte(1).where(:export_to_yandex_market => true).uniq
              products.each do |product|
                offer_vendor_model(xml, product)
              end
            }
          }
        } 
      end.to_xml
    end
    
    protected
    
    def offer_vendor_model(xml, product)
      opt = { 
        :id         => product.id,
        :available  => (product.has_stock?) ? true : false
        #, :type => 'vendor.model'
      }
        
      xml.offer(opt) do
        xml.url path_to_url("products/#{product.permalink}")
        xml.price product.price
        xml.currencyId @currencies.first.first
        xml.categoryId product.taxons.first.id
        product.images.take(10).each do |image|
          xml.picture path_to_url(image.attachment.url(:large, false))
        end
        xml.store false
        xml.pickup false
        xml.delivery true
        xml.name "#{product.name}"
        xml.description strip_tags(product.description) if product.description
      end
    end

    def path_to_url(path)
      "http://#{@host.sub(%r[^http://],'')}/#{path.sub(%r[^/],'')}"
    end

  end
end
