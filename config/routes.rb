Rails.application.routes.draw do
  get 'tags/index'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :images
  root 'images#index'

  post '/images/upload', to: "images#upload"
  get '/tags', to: "tags#index"
end
