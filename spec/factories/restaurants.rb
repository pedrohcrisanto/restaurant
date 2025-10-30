# frozen_string_literal: true

require 'securerandom'

FactoryBot.define do
  factory :restaurant do
    sequence(:name) { |n| "#{Faker::Restaurant.name} #{n}" }

    # Traits for different scenarios
    trait :with_menus do
      transient do
        menus_count { 3 }
      end

      after(:create) do |restaurant, evaluator|
        create_list(:menu, evaluator.menus_count, restaurant: restaurant)
      end
    end

    trait :with_full_menu do
      after(:create) do |restaurant|
        create(:menu, :with_items, restaurant: restaurant)
        restaurant.reload
      end
    end

    trait :popular do
      name { "#{Faker::Restaurant.name} - Popular #{SecureRandom.hex(3)}" }
    end

    trait :new_restaurant do
      name { "New #{Faker::Restaurant.name} #{SecureRandom.hex(3)}" }
    end

    # Factory variations
    factory :restaurant_with_menus, traits: [:with_menus]
    factory :restaurant_with_full_menu, traits: [:with_full_menu]
  end
end
