Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  
  get "up" => "rails/health#show", as: :rails_health_check



  # Defines the root path route ("/")
  # root "posts#index"

  # resources :user_libraries, only: [:create]

  resources :books, only: [:index, :show]
  # # do
  #   # POST 'user_libraries', to: 'user_libraries#create'
    
  # # end

  # post 'read_books/:id/review', to: 'reviews#create'

  # get '/dashboard', to: 'pages#dashboard'
end
