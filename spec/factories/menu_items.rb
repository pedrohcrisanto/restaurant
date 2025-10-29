# frozen_string_literal: true

FactoryBot.define do
  factory :menu_item do
    name { Faker::Food.dish }
  end
end

