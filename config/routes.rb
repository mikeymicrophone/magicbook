require 'resque/server'
Rails.application.routes.draw do
  devise_for :scribes, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords'}
  devise_for :magicians, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords', :sessions => 'sessions'}
  devise_for :muggles, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords'}

  resources :muggles do
    resources :books, :only => :index
    collection do
      get :invite
      post :submit
    end
  end
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
  resources :magicians, :only => [:index, :show] do
    resources :books, :only => :index
  end
  resources :purchased_books
  resources :editions do
    member do
      get :append
      put :release
    end
  end
  resources :books do
    resources :chapters do
      collection do
        get :free
      end
    end
  end
  resources :purchases
  resources :lists do
    resources :listed_items
    collection do
      get :review
      get :faq
    end
    member do
      put :approve
      put :reject
    end
  end
  resources :listed_items do
    collection do
      get :review
    end
    member do
      put :approve
      put :reject
    end
  end
  
  
  get '/wwemc' => 'landings#ways_we_enjoy_magic_cards', :as => 'wwemc'
  get '/font_guide' => 'landings#font_guide'
  
  devise_scope :magician do
    put 'passwords/establish', :to => 'passwords#establish', :as => 'establish_password'
    get 'confirmations/establish_access', :to => 'confirmations#establish_access'
  end
  
  get "/auth/:action/callback", :controller => "authentications", :constraints => { :action => /twitter|github|facebook/ }
  
  root :to => 'landings#home'
  mount Resque::Server.new, :at => "/resque"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
