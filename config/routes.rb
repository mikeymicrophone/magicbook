Rails.application.routes.draw do
  devise_for :magicians, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords'}
  resources :magicians, :only => [:index, :show]
  resources :purchased_books
  resources :editions
  resources :books
  resources :purchases
  
  devise_scope :magician do
    put 'passwords/establish', :to => 'passwords#establish', :as => 'establish_password'
    get 'confirmations/establish_access', :to => 'confirmations#establish_access'
  end
  
  root :to => 'purchases#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
