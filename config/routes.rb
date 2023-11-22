Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      resources :drivers, only: [:index]
      resources :throttler, only: [:index]
      post "throttler", to: "throttler#create"
      put "throttler", to: "throttler#update"
      get "throttler/:auth_token", to: "throttler#get_by_auth_token"
    end
  end
end
