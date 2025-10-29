# frozen_string_literal: true

module Menus
  class Update < Micro::Case
    include UseCaseHelpers

    attributes :menu, :params, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:menu) unless menu
      return failure_missing_params unless params

      return failure_validation(menu) unless update_menu

      Success result: { menu: menu }
    rescue StandardError => e
      handle_error(e, "menus.update", menu_id: menu&.id, params: params)
    end

    private

    def update_menu
      update_with_repo(repo, menu, params)
    end
  end
end
