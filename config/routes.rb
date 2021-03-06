# frozen_string_literal: true

Rails.application.routes.draw do
  get 'files/delete'
  get 'sessions/new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users do
    get 'page/:page', action: :index, on: :collection
  end
  get 'signup' => 'developers#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  resources :developers, only: %i[new create]
  post 'movie' => 'movies#new'
  get 'movies' => 'movies#index'
end
