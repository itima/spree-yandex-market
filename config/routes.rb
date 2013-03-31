Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :yandex_market_settings do
      member do
        match :general
        match :currency
        match :ware_property
        match :export_files
        get :run_export
      end
    end
  end
end
