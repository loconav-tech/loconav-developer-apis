Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      resources :drivers, only: [:index]
    end
  end
end
