require 'sidekiq/web'

Rails.application.routes.draw do
  resources :feeds
 
  resources :tests
  resources :domains
  get 'home/index'
  mount Sidekiq::Web =>'/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'domains#index'
  get "/search", to: 'domains#search', as: :search
  get "domain/bulk", to: "domains#update_bulk",as: :update_bulk
  get 'new', to: "rpzdata#create", as: :create
  get 'rpzdata', to: "rpzdata#show", as: :show
end
