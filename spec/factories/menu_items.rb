# frozen_string_literal: true

require 'securerandom'

FactoryBot.define do
  factory :menu_item do
    sequence(:name) { |n| "#{Faker::Food.dish} #{n}" }

    # Traits for different item types
    trait :appetizer do
      name { "#{Faker::Food.dish} (Appetizer) #{SecureRandom.hex(3)}" }
    end

    trait :main_course do
      name { "#{Faker::Food.dish} (Main Course) #{SecureRandom.hex(3)}" }
    end

    trait :dessert do
      name { "#{Faker::Food.dish} (Dessert) #{SecureRandom.hex(3)}" }
    end

    trait :beverage do
      name { "#{Faker::Food.dish} (Beverage) #{SecureRandom.hex(3)}" }
    end

    trait :expensive do
      # Will be used with menu_item_placement price
    end

    trait :cheap do
      # Will be used with menu_item_placement price
    end

    # Factory variations
    factory :appetizer_item, traits: [:appetizer]
    factory :main_course_item, traits: [:main_course]
    factory :dessert_item, traits: [:dessert]
  end
end
