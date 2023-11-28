Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "vehicle/telematics/last_known", to: "vehicle_stats#last_known"
      resources :drivers, only: [:index]
      resources :throttler, only: [:index, :create] do
        collection do
          get ":auth_token", action: :get_by_auth_token
          put "",action: :update
        end
      end
    end
  end
end
