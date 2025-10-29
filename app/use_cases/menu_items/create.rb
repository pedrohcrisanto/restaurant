# frozen_string_literal: true

module MenuItems
  class Create < Micro::Case
    include UseCaseHelpers

    attributes :params, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_missing_params unless params
      return failure_missing_name unless valid_name?(params[:name])

      menu_item = build_menu_item
      return failure_validation(menu_item) unless save_menu_item(menu_item)

      Success result: { menu_item: menu_item }
    rescue StandardError => e
      handle_error(e, "menu_items.create", params: params)
    end

    private

    def build_menu_item
      build_with_repo(repo, MenuItem, name: params[:name])
    end

    def save_menu_item(menu_item)
      save_with_repo(repo, menu_item)
    end
  end
end
