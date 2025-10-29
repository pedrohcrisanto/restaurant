# frozen_string_literal: true

module Api
  module V1
    class MenusController < BaseController
      def index
        result = Menus::ListForRestaurant.call(restaurant: @restaurant, repo: repository)
        return render_not_found("errors.restaurants.not_found") if result.failure?

        render_success(paginate(result[:menus]), MenuBlueprint)
      end

      def show
        result = find_menu
        return render_not_found("errors.menus.not_found") if result.failure?

        render_success(result[:menu], MenuBlueprint)
      end

      def create
        result = Menus::Create.call(restaurant: @restaurant, params: menu_params, repo: repository)
        return render_created(result[:menu], MenuBlueprint) if result.success?

        render_validation_error(result[:error])
      end

      def update
        execute_update(
          find_menu,
          Menus::Update,
          :menu,
          MenuBlueprint,
          "errors.menus.not_found",
          params: menu_params,
          repo: repository
        )
      end

      def destroy
        execute_destroy(
          find_menu,
          Menus::Destroy,
          :menu,
          "errors.menus.not_found",
          repo: repository
        )
      end

      private

      def find_menu
        Menus::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: repository)
      end

      def repository
        @repository ||= repository_for(:menu)
      end

      def menu_params
        params.fetch(:menu, params).permit(:name)
      end
    end
  end
end
