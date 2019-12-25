# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  get 'files/delete'
  get 'sessions/new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users
  get 'signup' => 'developers#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  resources :developers, only: %i[new create]
  post 'movie' => 'movies#new'
  get 'movies' => 'movies#index'

  mount Sidekiq::Web => '/sidekiq'
end
