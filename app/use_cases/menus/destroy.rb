# frozen_string_literal: true

module Menus
  class Destroy < Micro::Case
    include UseCaseHelpers

    attributes :menu, :repo

    def call!
      # Guard clause: validate menu presence
      return failure_not_found(:menu) unless menu

      destroy_menu
      Success result: { destroyed: true }
    rescue StandardError => e
      handle_error(e, "menus.destroy", menu_id: menu&.id)
    end

    private

    def destroy_menu
      destroy_with_repo(repo, menu)
    end
  end
end
