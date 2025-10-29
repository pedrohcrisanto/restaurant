# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Restaurant API V1",
        version: "v1",
        description: <<~DESC,
          # Restaurant Management API

          This API provides endpoints for managing restaurants, menus, and menu items.

          ## Features
          - CRUD operations for restaurants
          - Menu management per restaurant
          - Menu items with pricing
          - Nested resource support

          ## Authentication
          Currently, the API does not require authentication. Future versions will include JWT-based authentication.

          ## Rate Limiting
          No rate limiting is currently enforced.

          ## Versioning
          This is version 1 of the API. The version is included in the URL path.
        DESC
        contact: {
          name: "API Support",
          email: "support@example.com",
          url: "https://example.com/support",
        },
        license: {
          name: "MIT",
          url: "https://opensource.org/licenses/MIT",
        },
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server",
        },
        {
          url: "https://staging.example.com",
          description: "Staging server",
        },
        {
          url: "https://api.example.com",
          description: "Production server",
        },
      ],
      tags: [
        {
          name: "Restaurants",
          description: "Restaurant management endpoints",
        },
        {
          name: "Menus",
          description: "Menu management endpoints (nested under restaurants)",
        },
      ],
      components: {
        schemas: {
          # Restaurant schemas
          restaurant: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: "The Gourmet Kitchen" },
              menus: {
                type: :array,
                items: { "$ref" => "#/components/schemas/menu" },
              },
            },
            required: %w[id name],
          },
          restaurant_input: {
            type: :object,
            properties: {
              name: { type: :string, example: "The Gourmet Kitchen", minLength: 1 },
            },
            required: %w[name],
          },
          restaurant_list: {
            type: :array,
            items: { "$ref" => "#/components/schemas/restaurant" },
          },

          # Menu schemas
          menu: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: "Dinner Menu" },
              items: {
                type: :array,
                items: { "$ref" => "#/components/schemas/menu_item_placement" },
              },
            },
            required: %w[id name],
          },
          menu_input: {
            type: :object,
            properties: {
              name: { type: :string, example: "Dinner Menu", minLength: 1 },
            },
            required: %w[name],
          },
          menu_list: {
            type: :array,
            items: { "$ref" => "#/components/schemas/menu" },
          },

          # Menu Item Placement schemas
          menu_item_placement: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: "Grilled Salmon" },
              price: { type: :string, example: "24.99" },
            },
            required: %w[id name price],
          },

          # Error schemas
          error: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  message: { type: :string, example: "Resource not found" },
                  details: {
                    type: :array,
                    items: { type: :string },
                    example: ["Restaurant with id 999 not found"],
                  },
                },
              },
            },
            required: %w[error],
          },
          validation_error: {
            type: :object,
            properties: {
              error: {
                type: :object,
                properties: {
                  message: { type: :string, example: "Validation failed" },
                  details: {
                    type: :array,
                    items: { type: :string },
                    example: ["Name can't be blank", "Name has already been taken"],
                  },
                },
              },
            },
            required: %w[error],
          },
        },
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT",
            description: "JWT token for authentication (not currently required)",
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
