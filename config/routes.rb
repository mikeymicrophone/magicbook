Rails.application.routes.draw do
  resources :citations
  resources :paragraphs do
    member do
      get :append
    end
  end
  resources :sections do
    member do
      get :append
    end
  end
  resources :chapters do
    member do
      get :append
    end
  end
  devise_for :magicians, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords'}
  resources :magicians, :only => [:index, :show] do
    resources :books, :only => :index
  end
  resources :purchased_books
  resources :editions do
    member do
      get :append
    end
  end
  resources :books
  resources :purchases
  
  devise_scope :magician do
    put 'passwords/establish', :to => 'passwords#establish', :as => 'establish_password'
    get 'confirmations/establish_access', :to => 'confirmations#establish_access'
  end
  
  get "/auth/:action/callback", :controller => "authentications", :constraints => { :action => /twitter|github|facebook/ }
  
  root :to => 'landings#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
