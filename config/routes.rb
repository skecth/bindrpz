require 'sidekiq/web'

Rails.application.routes.draw do
  resources :categories
  resources :feeds
 
  resources :tests
  resources :domains
  get 'home/index'
  mount Sidekiq::Web =>'/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
  get "/search", to: 'domains#search', as: :search
  get "domain/bulk", to: "domains#update_bulk",as: :update_bulk
  get 'new', to: "rpzdata#create", as: :create
  get 'rpzdata', to: "rpzdata#show", as: :show
  get 'rpz_zones/:id', to: "feeds#show", as: :rpz_zones
  get 'feeds/new', to: "feeds#new", as: :rpz_new
  get 'feed/bulk_update', to: "domains#new", as: :bulk_update
  get 'feed/:id/blacklist', to: "domains#ne" ,as: :add_blacklist
  post 'feed/:id/blacklist', to: "domains#cf"

  get '/feed/admin', to: "feeds#admin", as: :admin_feed
  post 'instant_update/:id', to: "domains#instant_update", as: :instant_update

end
