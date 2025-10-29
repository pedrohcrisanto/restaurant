# frozen_string_literal: true

module Api
  module V1
    class MenuItemsController < BaseController
      before_action :set_restaurant

      def index
        result = MenuItems::ListForRestaurant.call(restaurant: @restaurant, repo: menu_items_repo)
        return render json: { error: { message: I18n.t('errors.restaurants.not_found') } }, status: :not_found if result.failure?

        render json: MenuItemBlueprint.render_as_hash(paginate(result[:items]))
      end

      def show
        result = MenuItems::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: menu_items_repo)
        return render json: { error: { message: I18n.t('errors.menu_items.not_found') } }, status: :not_found if result.failure?

        render json: MenuItemBlueprint.render_as_hash(result[:menu_item])
      end

      def create
        result = MenuItems::Create.call(params: menu_item_params, repo: menu_items_repo)
        if result.success?
          render json: MenuItemBlueprint.render_as_hash(result[:menu_item]), status: :created
        else
          render json: { error: { message: I18n.t('errors.validation_failed'), details: result[:error] } }, status: :unprocessable_entity
        end
      end

      def update
        find = MenuItems::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: menu_items_repo)
        return render json: { error: { message: I18n.t('errors.menu_items.not_found') } }, status: :not_found if find.failure?

        result = MenuItems::Update.call(menu_item: find[:menu_item], params: menu_item_params, repo: menu_items_repo)
        if result.success?
          render json: MenuItemBlueprint.render_as_hash(result[:menu_item])
        else
          render json: { error: { message: I18n.t('errors.validation_failed'), details: result[:error] } }, status: :unprocessable_entity
        end
      end

      def destroy
        find = MenuItems::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: menu_items_repo)
        return render json: { error: { message: I18n.t('errors.menu_items.not_found') } }, status: :not_found if find.failure?

        MenuItems::Destroy.call(menu_item: find[:menu_item], repo: menu_items_repo)
        head :no_content
      end

      private

      def set_restaurant
        @restaurant = Restaurant.find(params[:restaurant_id])
      end

      def menu_items_repo
        @menu_items_repo ||= Repositories::ActiveRecord::MenuItemsRepository.new
      end

      def menu_item_params
        if params.key?(:menu_item) || params.key?("menu_item")
          params.require(:menu_item).permit(:name)
        else
          params.permit(:name)
        end
      end
    end
  end
end
