Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Test routes for MongoMapper and Mongoid coexistence
  get "/" => "test#index"
  post "/mm_users" => "test#create_mm_user"
  post "/md_users" => "test#create_md_user"
  get "/users" => "test#list_users"
  
  # Defines the root path route ("/")
  # root "posts#index"
end
