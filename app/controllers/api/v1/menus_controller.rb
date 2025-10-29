# frozen_string_literal: true

module Api
  module V1
    class MenusController < BaseController
      before_action :set_restaurant

      def index
        result = Menus::ListForRestaurant.call(restaurant: @restaurant, repo: menus_repo)
        return render json: { error: { message: I18n.t('errors.restaurants.not_found') } }, status: :not_found if result.failure?

        render json: MenuBlueprint.render_as_hash(paginate(result[:menus]))
      end

      def show
        result = Menus::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: menus_repo)
        return render json: { error: { message: I18n.t('errors.menus.not_found') } }, status: :not_found if result.failure?

        render json: MenuBlueprint.render_as_hash(result[:menu])
      end

      def create
        result = Menus::Create.call(restaurant: @restaurant, params: menu_params, repo: menus_repo)
        if result.success?
          render json: MenuBlueprint.render_as_hash(result[:menu]), status: :created
        else
          render json: { error: { message: I18n.t('errors.validation_failed'), details: result[:error] } }, status: :unprocessable_entity
        end
      end

      def update
        find = Menus::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: menus_repo)
        return render json: { error: { message: I18n.t('errors.menus.not_found') } }, status: :not_found if find.failure?

        result = Menus::Update.call(menu: find[:menu], params: menu_params, repo: menus_repo)
        if result.success?
          render json: MenuBlueprint.render_as_hash(result[:menu])
        else
          render json: { error: { message: I18n.t('errors.validation_failed'), details: result[:error] } }, status: :unprocessable_entity
        end
      end

      def destroy
        find = Menus::FindForRestaurant.call(restaurant: @restaurant, id: params[:id], repo: menus_repo)
        return render json: { error: { message: I18n.t('errors.menus.not_found') } }, status: :not_found if find.failure?

        Menus::Destroy.call(menu: find[:menu], repo: menus_repo)
        head :no_content
      end

      private

      def set_restaurant
        @restaurant = Restaurant.find(params[:restaurant_id])
      end

      def menus_repo
        @menus_repo ||= Repositories::ActiveRecord::MenusRepository.new
      end

      def menu_params
        if params.key?(:menu) || params.key?("menu")
          params.require(:menu).permit(:name)
        else
          params.permit(:name)
        end
      end
    end
  end
end

