Rails.application.routes.draw do
  resources :listings
  resources :listings do
    member do
      get 'scrapeit', to: 'listings#scrapeit'
    end
  end
  root 'listings#index'
  get 'scrape_gallito', to: 'listings#scrape_gallito'

end
