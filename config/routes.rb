require 'sidekiq/web'

Revily::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  scope module: :v1, defaults: { format: :json }, constraints: Revily::ApiConstraints.new(version: 1, default: true) do
    put 'trigger'     => 'integration#trigger'
    put 'acknowledge' => 'integration#acknowledge'
    put 'resolve'     => 'integration#resolve'

    scope 'sms', as: 'sms' do
      post 'receive'  => 'sms#receive'
      post 'callback' => 'sms#callback'
      post 'fallback' => 'sms#fallback'
    end

    scope 'voice', as: 'voice' do
      post ''         => 'voice#index'
      post 'receive'  => 'voice#receive'
      get 'hangup'    => 'voice#hangup'
      post 'callback' => 'voice#callback'
      post 'fallback' => 'voice#fallback'
    end

    scope 'mail', as: 'mail' do
      post ''            => 'mail#receive'
      post 'cloudmailin' => 'mail#cloudmailin'
      post 'mandrill'    => 'mail#mandrill'
      post 'postmark'    => 'mail#postmark'
      post 'sendgrid'    => 'mail#sendgrid'
    end

    resources :services do
      member do
        put 'enable'
        put 'disable'
      end
      resources :incidents do
        member do
          put 'acknowledge'
          put 'resolve'
          put 'trigger'
        end
      end
    end
    resources :incidents, only: [ :index, :show, :update, :destroy ] do
      member do
        put 'acknowledge'
        put 'resolve'
        put 'trigger'
      end
    end

    resources :policies do
      resources :policy_rules do
        collection do
          post :sort
        end
      end
    end

    resources :schedules do
      resources :schedule_layers, path: :layers, as: :layers
      resources :schedule_layers
      member do
        get 'policy_rules'
        get 'users'
        get 'on_call'
      end
    end

    resources :users do
      resources :contacts
    end
    
    resources :hooks
    resources :events, only: [ :index, :show ]
  end

  devise_for :users, controllers: { registrations: 'v1/users/registrations', sessions: 'v1/users/sessions' }
  devise_for :services, skip: [ :sessions ]

  root to: 'v1/root#index'
end
