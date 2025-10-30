# frozen_string_literal: true

module ResourceActions
  extend ActiveSupport::Concern

  private

  # Executes a use case and yields the result if successful.
  # Returns early with not_found error if the use case fails.
  #
  # @param use_case_result [Micro::Case::Result] The result from a find use case
  # @param error_key [String] I18n key for the not found error message
  # @yield [result] Yields the successful result to the block
  # @return [void] Renders response and returns
  #
  # Example:
  #   def update
  #     with_resource(find_restaurant, "errors.restaurants.not_found") do |find_result|
  #       result = Restaurants::Update.call(
  #         restaurant: find_result[:restaurant],
  #         params: resource_params,
  #         repo: repository
  #       )
  #       return render_success(result[:restaurant], RestaurantBlueprint) if result.success?
  #       render_validation_error(result[:error])
  #     end
  #   end
  def with_resource(use_case_result, error_key)
    return render_not_found(error_key) if use_case_result.failure?

    yield use_case_result
  end

  # Executes an update action with standard pattern:
  # 1. Find resource
  # 2. Update resource
  # 3. Render success or validation error
  #
  # @param find_use_case [Micro::Case::Result] Result from find use case
  # @param update_use_case_class [Class] Update use case class
  # @param resource_key [Symbol] Key for the resource in the result hash
  # @param blueprint_class [Class] Blueprint class for rendering
  # @param error_key [String] I18n key for not found error
  # @param update_params [Hash] Additional parameters for update use case
  #
  # Example:
  #   def update
  #     execute_update(
  #       find_restaurant,
  #       Restaurants::Update,
  #       :restaurant,
  #       RestaurantBlueprint,
  #       "errors.restaurants.not_found",
  #       params: resource_params,
  #       repo: repository
  #     )
  #   end
  # rubocop:disable Metrics/ParameterLists
  def execute_update(find_use_case, update_use_case_class, resource_key, blueprint_class, error_key, **update_params)
    # rubocop:enable Metrics/ParameterLists
    with_resource(find_use_case, error_key) do |find_result|
      result = update_use_case_class.call(
        resource_key => find_result[resource_key],
        **update_params
      )
      return render_success(result[resource_key], blueprint_class) if result.success?

      render_validation_error(result[:error])
    end
  end

  # Executes a destroy action with standard pattern:
  # 1. Find resource
  # 2. Destroy resource
  # 3. Render no_content
  #
  # @param find_use_case [Micro::Case::Result] Result from find use case
  # @param destroy_use_case_class [Class] Destroy use case class
  # @param resource_key [Symbol] Key for the resource in the result hash
  # @param error_key [String] I18n key for not found error
  # @param destroy_params [Hash] Additional parameters for destroy use case
  #
  # Example:
  #   def destroy
  #     execute_destroy(
  #       find_restaurant,
  #       Restaurants::Destroy,
  #       :restaurant,
  #       "errors.restaurants.not_found",
  #       repo: repository
  #     )
  #   end
  def execute_destroy(find_use_case, destroy_use_case_class, resource_key, error_key, **destroy_params)
    with_resource(find_use_case, error_key) do |find_result|
      destroy_use_case_class.call(resource_key => find_result[resource_key], **destroy_params)
      render_no_content
    end
  end
end
