# frozen_string_literal: true

module Api
  module V1
    class RestaurantsController < BaseController

      def index
        result = Restaurants::List.call(repo: restaurants_repo)
        relation = result[:relation]
        records = paginate(relation)
        render json: RestaurantBlueprint.render_as_hash(records)
      end

      def show
        result = Restaurants::Find.call(repo: restaurants_repo, id: params[:id])
        return render_error(I18n.t('errors.restaurants.not_found'), status: :not_found) if result.failure?

        render json: RestaurantBlueprint.render_as_hash(result[:restaurant])
      end

      def create
        result = Restaurants::Create.call(repo: restaurants_repo, params: restaurant_params)
        if result.success?
          render json: RestaurantBlueprint.render_as_hash(result[:restaurant]), status: :created
        else
          render_error(I18n.t('errors.validation_failed'), status: :unprocessable_entity, details: result[:error])
        end
      end

      def update
        find = Restaurants::Find.call(repo: restaurants_repo, id: params[:id])
        return render_error(I18n.t('errors.restaurants.not_found'), status: :not_found) if find.failure?

        result = Restaurants::Update.call(repo: restaurants_repo, restaurant: find[:restaurant], params: restaurant_params)
        if result.success?
          render json: RestaurantBlueprint.render_as_hash(result[:restaurant])
        else
          render_error(I18n.t('errors.validation_failed'), status: :unprocessable_entity, details: result[:error])
        end
      end

      def destroy
        find = Restaurants::Find.call(repo: restaurants_repo, id: params[:id])
        return render_error(I18n.t('errors.restaurants.not_found'), status: :not_found) if find.failure?

        Restaurants::Destroy.call(repo: restaurants_repo, restaurant: find[:restaurant])
        head :no_content
      end

      private

      def restaurant_params
        if params.key?(:restaurant) || params.key?("restaurant")
          params.require(:restaurant).permit(:name)
        else
          params.permit(:name)
        end
      end

      def restaurants_repo
        @restaurants_repo ||= Repositories::ActiveRecord::RestaurantsRepository.new
      end
    end
  end
end
