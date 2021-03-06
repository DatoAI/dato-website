Rails.application.routes.draw do
  resources :invitations
  resources :competitions do
    member do
      put 'disable'
      put 'enable'
    end
    resources :acceptances, only: [:new, :create]
    resources :rankings, only: [:index]
    resources :submissions, only: [:index, :show, :new, :create, :destroy] do
      collection do
        get 'summary'
      end
    end
  end
  get '/data/:uuid', to: 'attachments#show', as: 'data'
  resources :instructions, only: [:show]
  resources :users, only: [:show, :edit, :update]
  
  get 'dashboard/home'
  get 'dashboard/list_users'
  get 'dashboard/export_users_to_csv'

  resources :teams, only: [:show, :new, :edit, :create, :update]
  devise_for :users,
    path: 'auth',
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  authenticated :user do
    root to:'competitions#index'
  end
end
