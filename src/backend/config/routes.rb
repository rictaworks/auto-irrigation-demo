Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    get "session", to: "sessions#show"
    get "field_settings", to: "field_settings#show"
    post "field_settings", to: "field_settings#create"
    get "sensor", to: "sensor_readings#show"
    post "sensor", to: "sensor_readings#create"
    post "irrigate", to: "irrigations#create"
    get "irrigation_logs", to: "irrigation_logs#index"
  end
end
