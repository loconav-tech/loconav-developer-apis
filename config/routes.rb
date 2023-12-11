Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      resources :drivers, only: [:index]

      # VT APIs
      namespace :vt do
        resources :livestream, only: %i[index create update destroy], controller: "livestream"
        resources :vod, only: %i[index create], controller: "vod"
        resources :lookups, only: [:index], controller: "data"
      end
    end
  end
end
