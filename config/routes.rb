Rails.application.routes.draw do

  root to: 'welcome#index'

  namespace :api do
    namespace :v1 do
      resources :drivers, only: [:index]

      resources :trips, only: %i[index create], controller: "trips/trips" do
        collection do
          put :update
          delete :destroy
        end
      end

      resources :throttler, only: %i[index create] do
        collection do
          get ":auth_token", action: :get_by_auth_token
          put "", action: :update
        end
      end

      namespace :vehicle do
        resources :video, only: %i[index create], controller: "vod"
        namespace :telematics do
          resources :livestream, only: %i[index create update destroy], controller: "livestream"
          post :history, controller: "vehicle_stats"
          post :last_known, controller: "vehicle_stats"
        end
        namespace :video do
          resources :lookups, only: %i[index create], controller: "data"
        end
      end
    end
  end

  # ERROR HANDLING
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # SWAGGER
  mount Rswag::Ui::Engine => "/documentation", as: "rswag_ui"
  mount Rswag::Api::Engine => "/documentation/api-docs", as: "rswag_api"

end
