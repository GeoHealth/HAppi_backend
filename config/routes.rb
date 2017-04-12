Rails.application.routes.draw do
  namespace :data_analysis do
    get 'users_having_same_symptoms/index'
    get 'users_having_same_symptoms/new'
    post 'users_having_same_symptoms/create'

  end

  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks], controllers: {
      registrations: 'registrations'
  }

  api_version(:module => 'V1', :path => {:value => 'v1'}, :default => true) do
    resources :occurrences, :only => [:create, :index]
    resources :symptoms, :only => [:index]
    resources :symptoms_user, :only => [:index, :create]
    resource :reports, :only => [:create]
    resource :report, :only => [:show]
    delete 'symptoms_user' => 'symptoms_user#destroy'
    delete 'occurrences' => 'occurrences#destroy'
    get 'symptoms/occurrences' => 'symptoms#occurrences'
    get 'stats/count' => 'stats#count'
  end

  # :nocov:
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
  # :nocov:
end
