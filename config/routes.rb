Rails.application.routes.draw do
  devise_for :magicians
  resources :magicians, :only => [:index, :show]
  resources :purchased_books
  resources :editions
  resources :books
  resources :purchases
  
  root :to => 'purchases#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
