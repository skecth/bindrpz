require 'sidekiq/web'

Rails.application.routes.draw do
  get 'custom_blacklists/new_bulk' => 'custom_blacklists#new_bulk', as: :new_bulk
  resources :custom_blacklists
  resources :feed_zones
  
  resources :categories
  resources :feeds 
  resources :zones
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
  # get 'rpz_zones/:id', to: "feeds#show", as: :rpz_zones
  get 'feeds/new', to: "feeds#new", as: :rpz_new
  get 'feed/bulk_update', to: "domains#new", as: :bulk_update
  get 'feed/:id/blacklist', to: "domains#ne" ,as: :add_blacklist
  post 'feed/:id/blacklist', to: "domains#cf"
  #28/10
  get 'rpz_zone/:id', to: "zones#show", as: :rpz_zone
  post 'rpz_zone/:id', to:"feed_zones#pull", as: :pull
  get '/feed/admin', to: "feeds#admin", as: :admin_feed
  post 'instant_update/:id', to: "domains#instant_update", as: :instant_update
  post 'feed_zone/new', to: "feed_zones#check_feed", as: :check_feed_id
  get '/add/:id', to: "feed_zones#feed_upload_check", as: :feed_zone_check
  post '/add/:id', to: "feed_zones#feed_upload_check", as: :new_feed_check
  get 'zone/manage_zone/:id', to: "feed_zones#index",as: :index_feedZone

  post 'bulk_create' => 'feeds#bulk_create', as: :bulk_create
  # get 'single_form' => 'feeds#new', as: :single_form

end
