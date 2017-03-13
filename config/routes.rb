Rails.application.routes.draw do
  resources :books
  resources :purchases
  
  root :to => 'purchases#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
