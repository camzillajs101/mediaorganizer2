Rails.application.routes.draw do
  get 'images/show'
  get 'images/index'
  get 'images/edit'
  get 'images/new'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
