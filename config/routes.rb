Rails.application.routes.draw do
  # Rswag API documentation (only if gems loaded)
  if defined?(Rswag::Ui::Engine)
    mount Rswag::Ui::Engine => "/api-docs"
  end
  if defined?(Rswag::Api::Engine)
    mount Rswag::Api::Engine => "/api-docs"
  end

  namespace :api do
    namespace :v1 do
      resources :restaurants do
        resources :menus
        resources :menu_items
      end

      # Import endpoint for Level 3
      post "imports/restaurants_json", to: "imports#restaurants_json"
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
