# frozen_string_literal: true

module Api
  module V1
    class RestaurantsController < BaseController
      def index
        result = Restaurants::List.call(repo: repository)
        render_success(paginate(result[:relation]), RestaurantBlueprint)
      end

      def show
        result = find_restaurant
        return render_not_found("errors.restaurants.not_found") if result.failure?

        render_success(result[:restaurant], RestaurantBlueprint)
      end

      def create
        result = Restaurants::Create.call(repo: repository, params: restaurant_params)
        return render_created(result[:restaurant], RestaurantBlueprint) if result.success?

        render_validation_error(result[:error])
      end

      def update
        execute_update(
          find_restaurant,
          Restaurants::Update,
          :restaurant,
          RestaurantBlueprint,
          "errors.restaurants.not_found",
          repo: repository,
          params: restaurant_params
        )
      end

      def destroy
        execute_destroy(
          find_restaurant,
          Restaurants::Destroy,
          :restaurant,
          "errors.restaurants.not_found",
          repo: repository
        )
      end

      private

      def find_restaurant
        Restaurants::Find.call(repo: repository, id: params[:id])
      end

      def repository
        @repository ||= repository_for(:restaurant)
      end

      def restaurant_params
        params.fetch(:restaurant, params).permit(:name)
      end
    end
  end
end
