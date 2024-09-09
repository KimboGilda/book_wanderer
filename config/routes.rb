Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get 'random_books', to: 'pages#random_books', defaults: { format: :json }

  get "up" => "rails/health#show", as: :rails_health_check



  # Defines the root path route ("/")
  # root "posts#index"

  get 'books_for_carousel', to: 'pages#load_user_content'

  # resources :books, only: [:index, :show]
  resources :books do
    resources :reviews, only: [:create]
    resources :user_libraries, only: [:create, :destroy]
    resources :read_books, only: [:destroy, :create]
  end
  resources :read_books, only: [:index, :destroy]
  resources :user_libraries, only: [:index, :destroy]
  resources :bookstores, only: [:index]
  
end
