Rails.application.routes.draw do

  mount Resque::Server.new, at: '/resque'

  devise_for :users, controllers: { sessions: 'users/sessions' }

  root to: 'administrative_interface#index'

  resources :incoming_messages, only: [:create]
  resources :first_responders
  resources :incidents, except: [:edit, :update]
  resources :settings, only: [:index, :show, :edit, :update]
  resources :simulations, only: [:new, :create]
  resources :hospitals, except: [:show] do
    resources :medical_doctors, except: [:index, :show]
  end
  resources :users, except: [:show] do
    post :set_data_center_permissions
  end
  resources :white_listed_phone_numbers, except: [:show]
  resources :administrators, except: [:show]
  resources :data_centers, except: [:show]
  resources :unregistered_parties, only: [:index]
  resources :categories, except: [:show] do
    resources :subcategories, except: [:index, :show]
  end

  post 'settings/set_user_data_center'

  match "incoming_messages", :to => "incoming_messages#create", via: :get

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :first_responders, only: [:index] do
        post 'log_in'
        post 'log_out'
        post 'message'
      end
      resources :incidents, only: [:index, :show] do
        post 'cancel_incident'
        post 'edit_comment'
      end
      resources :incoming_messages, only: [:create]
      post 'incoming_messages/admin_reporting_party'
    end

    namespace :v2 do
      namespace :users do
        devise_scope :user do
          post 'sessions' => 'sessions#create'
          delete 'sessions' => 'sessions#destroy'
        end
      end
      resources :incidents, only: [:index, :show, :create, :destroy] do
        get 'message_log', on: :member
        patch 'edit_comment'
        post 'cancel_incident'
      end
      resources :first_responders, only: [:index, :create, :update, :destroy] do
        get 'performance_report', on: :member
        post 'log_in'
        post 'log_out'
      end
      resources :hospitals, only: [:index, :create, :update, :destroy]
      resources :medical_doctors, only: [:index, :create, :update, :destroy]
      resources :data_centers, only: [:index, :create, :update, :destroy]
      resources :users, only: [:index, :create, :update, :destroy]
      resources :settings, only: [:index, :update]
      resources :categories, only: [:index, :create, :update, :destroy]
      resources :subcategories, only: [:index, :create, :update, :destroy]
      resources :outgoing_messages, only: [:create]
      resources :unregistered_parties, only: [:index]
      resources :administrators, only: [:index, :create, :update, :destroy]
      resources :alerts, only: [:index]
      resources :dispatch_phone_numbers, only: [:index, :create, :update, :destroy]
    end
  end
end
