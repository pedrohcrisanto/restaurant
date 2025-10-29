# frozen_string_literal: true

module MenuItems
  class Create < Micro::Case
    attributes :params, :repo

    def call!
      name = params[:name]
      return Failure(:invalid, result: { error: [I18n.t('errors.validation.name_required')] }) if name.to_s.strip.empty?

      menu_item = repo ? repo.build(name: name) : MenuItem.new(name: name)

      if (repo ? repo.save(menu_item) : menu_item.save)
        Success result: { menu_item: menu_item }
      else
        Failure :invalid, result: { error: menu_item.errors.full_messages }
      end
    end
  end
end

