Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :images
  root 'images#index'

  get '/upload', to: "images#fileupload"
  post '/upload', to: "images#upload"
  get '/tags', to: "tags#index"
  get '/play/:id', to: "images#play"
end
