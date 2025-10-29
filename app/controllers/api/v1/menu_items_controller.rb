# frozen_string_literal: true

module Api
  module V1
    class MenuItemsController < BaseController
      def index
        result = MenuItems::ListForRestaurant.call(restaurant: @restaurant, repo: repository)
        return render_not_found("errors.restaurants.not_found") if result.failure?

        render_success(paginate(result[:items]), MenuItemBlueprint)
      end

      def show
        result = find_menu_item
        return render_not_found("errors.menu_items.not_found") if result.failure?

        render_success(result[:menu_item], MenuItemBlueprint)
      end

      def create
        result = MenuItems::Create.call(params: menu_item_params, repo: repository)
        return render_created(result[:menu_item], MenuItemBlueprint) if result.success?

        render_validation_error(result[:error])
      end

      def update
        execute_update(
          find_menu_item,
          MenuItems::Update,
          :menu_item,
          MenuItemBlueprint,
          "errors.menu_items.not_found",
          params: menu_item_params,
          repo: repository
        )
      end

      def destroy
        execute_destroy(
          find_menu_item,
          MenuItems::Destroy,
          :menu_item,
          "errors.menu_items.not_found",
          repo: repository
        )
      end

      private

      def find_menu_item
        MenuItems::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: repository)
      end

      def repository
        @repository ||= repository_for(:menu_item)
      end

      def menu_item_params
        params.require(:menu_item).permit(:name)
      end
    end
  end
end
