Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  resources :users

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :users, only: %i[index create show update destroy]
      resources :states, only: [] do
        get 'cities', on: :member
      end
      post '/auth/login', to: 'authentication#login'
      post '/auth/signup', to: 'authentication#signup'
      post 'auth/password/new', to: 'authentication#reset_password_token'
      post 'auth/password/edit', to: 'authentication#edit_password'
    end
  end

  resources :states, only: [] do
    get 'cities', on: :member
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'users#index'
  match '*path', to: 'application#render_404', via: :all
end
