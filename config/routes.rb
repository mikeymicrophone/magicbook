Rails.application.routes.draw do
  devise_for :mages, controllers: {
    confirmations: 'confirmations',
    passwords: 'passwords',
    omniauth_callbacks: 'omniauth_callbacks'
  }

  resource :magic_link, only: [:new, :create]
  get 'magic-link/:token', to: 'magic_links#show', as: :consume_magic_link

  resource :passkey, only: [] do
    collection do
      post :registration_options
      post :register
      post :authentication_options
      post :authenticate
    end
  end

  resources :invitations, only: [:index, :show] do
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
  resources :mages, only: [:index] do
    collection do
      post :ramp
    end
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
  namespace :admin do
    resources :tag_contexts do
      resources :tags, except: [:index, :show]
    end
    resources :taggings, only: [:create, :destroy]
  end
  resources :cards, only: [:show] do
    resources :card_function_assignments, only: [:create]
  end
  resources :card_sets, :only => [:index, :show], :param => :code
  resources :card_functions, only: [:index, :show], param: :slug
  
  get '/privacy' => 'landings#privacy', :as => 'privacy_policy'
  get '/data_deletion' => 'landings#data_deletion', :as => 'data_deletion'
  
  get '/wwemc' => 'landings#ways_we_enjoy_magic_cards', :as => 'wwemc'
  get '/coaching' => 'landings#coaching', :as => 'coaching'
  
  get '/font_guide' => 'landings#font_guide'
  
  devise_scope :mage do
    put 'passwords/establish', :to => 'passwords#establish', :as => 'establish_password'
    get 'confirmations/establish_access', :to => 'confirmations#establish_access'
  end
  
  root :to => 'landings#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
