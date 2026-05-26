Rails.application.routes.draw do
  get  "test",       to: "test#index"
  post "test/toast", to: "test#toast", as: :test_toast

  get  "setup", to: "setups#new",    as: :setup
  post "setup", to: "setups#create"

  resource :session
  resources :notifications, only: %i[ index ] do
    collection do
      scope module: :notifications do
        resource :read_status, only: :update
      end
    end
  end
  namespace :spaces do
    resource :handle_suggestion, only: :show
  end
  namespace :users do
    resource :handle_suggestion, only: :show
  end
  resources :spaces, only: %i[ index show new create ], param: :handle do
    scope module: :spaces do
      resource  :management,    only: %i[ show update ]
      resource  :search,        only: %i[ show ]
      resource  :subscription,  only: %i[ create destroy ]
      resource  :favorite,      only: %i[ create destroy ]
      resources :members,       only: %i[ update destroy ]
      resources :requests,      only: %i[ create update ]
      resources :waves,         only: %i[ create ]
      resources :entries, only: %i[ index new create show edit update destroy ] do
        resources :comments, only: %i[ create destroy ]
        resource  :bookmark, only: %i[ create destroy ]
        resource  :like,     only: %i[ create destroy ]
        resource  :event_response, only: %i[ create update ]
        resource  :poll_answer,    only: %i[ create ]
      end
    end
  end
  resources :bookmarks, only: %i[ index ]
  namespace :admin do
    root to: "users#index"
    resource :account, only: %i[ edit update ]
    resources :invitations, only: :create, module: :users
    resources :users, only: %i[ index show edit update ] do
      scope module: :users do
        resource :password_reset, only: :create
      end
    end
  end
  resources :invitations, param: :token, only: %i[ edit update ]
  get "profile", to: "users#edit", as: :profile
  resource :user, only: %i[ update destroy ]
  scope :user, module: "users" do
    resource :password, only: :update, as: :user_password
  end
  resources :passwords, param: :token
  resources :magic_links, param: :token, only: %i[ new create show ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "feed#index"
end
