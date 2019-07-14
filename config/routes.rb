# frozen_string_literal: true

Rails.application.routes.draw do
  get 'sessions/new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'users' => 'users#index'
  get 'users/new' => 'users#new'
  post 'users' => 'users#create'
  get 'signup' => 'developers#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  resources :developers
end
