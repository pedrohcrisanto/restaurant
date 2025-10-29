# frozen_string_literal: true

module Menus
  class Destroy < Micro::Case
    attributes :menu, :repo

    def call!
      return Failure(:not_found, result: { error: I18n.t('errors.menus.not_found') }) if menu.nil?

      repo ? repo.destroy(menu) : menu.destroy
      Success result: { destroyed: true }
    end
  end
end

