require 'spree_core'

module SpreeYandexMarket
  class Engine < Rails::Engine
    engine_name 'spree_yandex_market'
    isolate_namespace Spree
    
    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/**/*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

#    rake_tasks do
#      load File.join(File.dirname(__FILE__), "tasks/yandex_market.rake")
#    end

    initializer "yandex_market.preferences",  :before => :load_config_initializers do |app|
      SpreeYandexMarket::Config = Spree::YandexMarketConfiguration.new
    end

    config.to_prepare &method(:activate).to_proc
  end
  
end
