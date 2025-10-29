# frozen_string_literal: true

module MenuItems
  class Update < Micro::Case
    attributes :menu_item, :params, :repo

    def call!
      return Failure(:not_found, result: { error: I18n.t('errors.menu_items.not_found') }) if menu_item.nil?

      if (repo ? repo.update(menu_item, params) : menu_item.update(params))
        Success result: { menu_item: menu_item }
      else
        Failure :invalid, result: { error: menu_item.errors.full_messages }
      end
    end
  end
end

