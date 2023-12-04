Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :drivers, only: [:index]
    end
  end
end
