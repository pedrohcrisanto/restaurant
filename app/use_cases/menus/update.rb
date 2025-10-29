# frozen_string_literal: true

module Menus
  class Update < Micro::Case
    attributes :menu, :params, :repo

    def call!
      return Failure(:not_found, result: { error: I18n.t('errors.menus.not_found') }) if menu.nil?

      if (repo ? repo.update(menu, params) : menu.update(params))
        Success result: { menu: menu }
      else
        Failure :invalid, result: { error: menu.errors.full_messages }
      end
    end
  end
end

