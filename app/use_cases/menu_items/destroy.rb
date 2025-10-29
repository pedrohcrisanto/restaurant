# frozen_string_literal: true

module MenuItems
  class Destroy < Micro::Case
    include UseCaseHelpers

    attributes :menu_item, :repo

    def call!
      # Guard clause: validate menu_item presence
      return failure_not_found(:menu_item) unless menu_item

      destroy_menu_item
      Success result: { destroyed: true }
    rescue StandardError => e
      handle_error(e, "menu_items.destroy", menu_item_id: menu_item&.id)
    end

    private

    def destroy_menu_item
      destroy_with_repo(repo, menu_item)
    end
  end
end
