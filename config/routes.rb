Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      resources :drivers, only: [:index]
      # VT APIs
      resources :livestream, only: %i[index create update destroy], controller: "vt_livestream"
      resources :vod, only: %i[index create], controller: "vt_vod"
      resources :lookups, only: [:index], controller: "vt_data"
      resources :throttler, only: [:index, :create] do
        collection do
          get ":auth_token", action: :get_by_auth_token
          put "",action: :update
        end
      end
    end
  end
end
