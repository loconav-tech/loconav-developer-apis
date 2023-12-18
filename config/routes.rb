Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      resources :drivers, only: [:index]

      namespace :vehicle do
        resources :video, only: %i[index create], controller: "vod"
        namespace :telematics do
          resources :livestream, only: %i[index create update destroy], controller: "livestream"
        end
        namespace :video do
          resources :lookups, only: [:index], controller: "data"
        end
      end
    end
  end
end
