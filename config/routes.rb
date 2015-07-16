Rails.application.routes.draw do
  resources :listings
  resources :listings do
    member do
      get 'scrapeit', to: 'listings#scrapeit'
      patch 'add_similar', to: 'listings#add_similar'

    end
  end
  root 'listings#index'
  get 'scrape_all', to: 'listings#scrape_all'
  get 'external_scrape_gallito', to: 'listings#external_scrape_gallito'

end
