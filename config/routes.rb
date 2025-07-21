Rails.application.routes.draw do
  # Webhook for STT callbacks (no locale needed)
  post '/api/stt-webhook', to: 'webhooks#stt_callback'

  # Health check (no locale needed)
  get "up" => "rails/health#show", as: :rails_health_check

  # Language switching routes
  scope "(:locale)", locale: /ko|en/, defaults: { locale: 'ko' } do
    devise_for :users, skip: [:registrations]
    devise_scope :user do
      get '/users/edit', to: 'devise/registrations#edit', as: :edit_user_registration
      patch '/users', to: 'devise/registrations#update', as: :user_registration
    end
    
    # Admin routes (protected)
    authenticate :user, lambda { |u| u.is_admin? } do
      namespace :admin do
        root 'dashboard#index'
        resources :interview_templates do
          resources :template_questions, only: [:new, :create, :edit, :update, :destroy]
        end
        resources :interviews, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
          member do
            post :transcribe_answer
          end
        end
        get 'account', to: 'account#show'
        patch 'account', to: 'account#update'
      end
    end

    # Public facing routes for interviewees
    namespace :public do
      resources :interviews, param: :unique_link_id, only: [:show] do
        resources :answers, only: [:create]
      end
    end

    # Home routes
    get 'home/index'
    root 'home#index'
  end
end
