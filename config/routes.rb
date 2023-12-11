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

  # ERROR HANDLING
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # SWAGGER
  mount Rswag::Ui::Engine => "/documentation", as: "rswag_ui"
  mount Rswag::Api::Engine => "/documentation/api-docs", as: "rswag_api"
end
