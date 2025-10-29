# frozen_string_literal: true

FactoryBot.define do
  factory :menu_item_placement do
    association :menu
    association :menu_item
    price { Faker::Commerce.price(range: 1.0..50.0) }
  end
end

