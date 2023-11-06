Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      post "vehicle/telematics/history", to: "vehicle_stats#history"
      resources :drivers, only: [:index]
    end
  end
end
