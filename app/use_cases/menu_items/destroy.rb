# frozen_string_literal: true

module MenuItems
  class Destroy < Micro::Case
    attributes :menu_item, :repo

    def call!
      return Failure(:not_found, result: { error: I18n.t('errors.menu_items.not_found') }) if menu_item.nil?

      repo ? repo.destroy(menu_item) : menu_item.destroy
      Success result: { destroyed: true }
    end
  end
end

