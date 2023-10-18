require 'resque/server'
Rails.application.routes.draw do
  devise_for :scribes, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords'}
  devise_for :magicians, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords', :sessions => 'sessions', :omniauth_callbacks => 'callbacks'}
  devise_for :muggles, :controllers => {:confirmations => 'confirmations', :passwords => 'passwords'}

  resources :muggles do
    resources :books, :only => :index
    collection do
      get :invite
      post :submit
    end
  end
  resources :citations do
    member do
      put :delay
      put :promote
    end
  end
  resources :paragraphs do
    member do
      get :append
      put :delay
      put :promote
    end
  end
  resources :sections do
    member do
      get :append
      put :delay
      put :promote
    end
  end
  resources :chapters do
    member do
      get :append
      put :promote
      get :edit_as
    end
  end
  resources :magicians, :only => [:index, :show] do
    collection do
      post :ramp
    end
    resources :books, :only => :index
  end
  resources :purchased_books
  resources :editions do
    member do
      get :append
      put :release
      put :freeze
    end
  end
  resources :books do
    resources :chapters do
      collection do
        get :free
      end
      member do
        get :next
      end
    end
  end
  resources :purchases do
    member do
      get :claim
    end
  end
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
      get :paragraphs_for
    end
    member do
      put :approve
      put :reject
      put :move_up
      put :move_down
      get :suggest_revision
    end
  end
  resources :card_inclusions
  
  get '/privacy' => 'landings#privacy', :as => 'privacy_policy'
  get '/data_deletion' => 'landings#data_deletion', :as => 'data_deletion'
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
