require 'sidekiq/web'

Rails.application.routes.draw do
  resources :categories
  resources :sources
  resources :domains
  get 'home/index'
  mount Sidekiq::Web =>'/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'domains#index'
  get "/search", to: 'domains#search', as: :search
  get "test", to: 'domains#write', as: :test
  get "domain/bulk", to: "domains#update_bulk",as: :update_bulk
end
