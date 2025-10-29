# frozen_string_literal: true

FactoryBot.define do
  factory :menu_item_placement do
    association :menu
    association :menu_item
    price { Faker::Commerce.price(range: 5.0..30.0) }

    # Traits for different price ranges
    trait :cheap do
      price { Faker::Commerce.price(range: 1.0..10.0) }
    end

    trait :moderate do
      price { Faker::Commerce.price(range: 10.0..25.0) }
    end

    trait :expensive do
      price { Faker::Commerce.price(range: 25.0..100.0) }
    end

    trait :free do
      price { 0.0 }
    end

    trait :with_restaurant do
      transient do
        restaurant { nil }
      end

      menu { association :menu, restaurant: restaurant || create(:restaurant) }
    end

    # Factory variations
    factory :cheap_placement, traits: [:cheap]
    factory :expensive_placement, traits: [:expensive]
  end
end
