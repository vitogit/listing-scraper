Rails.application.routes.draw do
  resources :listings
  resources :listings do
    member do
      get 'scrapeit', to: 'listings#scrapeit'
      patch 'add_similar', to: 'listings#add_similar'
    end
  end
  root 'listings#index'
  get 'scrape_ml', to: 'listings#scrape_ml'
  get 'scrape_gallito', to: 'listings#scrape_gallito'
  get 'duplicates', to: 'listings#duplicates'
  get 'statistics', to: 'listings#statistics'
  # get 'external_scrape_gallito', to: 'listings#external_scrape_gallito'

end
