# frozen_string_literal: true

module MenuItems
  class Update < Micro::Case
    include UseCaseHelpers

    attributes :menu_item, :params, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:menu_item) unless menu_item
      return failure_missing_params unless params

      return failure_validation(menu_item) unless update_menu_item

      Success result: { menu_item: menu_item }
    rescue StandardError => e
      handle_error(e, "menu_items.update", menu_item_id: menu_item&.id, params: params)
    end

    private

    def update_menu_item
      update_with_repo(repo, menu_item, params)
    end
  end
end
