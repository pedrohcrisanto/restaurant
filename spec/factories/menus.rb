# frozen_string_literal: true

FactoryBot.define do
  factory :menu do
    association :restaurant
    sequence(:name) { |n| "Menu #{n}" }

    # Traits for different menu types
    trait :breakfast do
      name { "Breakfast Menu" }
    end

    trait :lunch do
      name { "Lunch Menu" }
    end

    trait :dinner do
      name { "Dinner Menu" }
    end

    trait :with_items do
      transient do
        items_count { 5 }
      end

      after(:create) do |menu, evaluator|
        evaluator.items_count.times do
          menu_item = create(:menu_item)
          create(:menu_item_placement, menu: menu, menu_item: menu_item)
        end
      end
    end

    trait :with_expensive_items do
      after(:create) do |menu|
        menu_item = create(:menu_item, :expensive)
        create(:menu_item_placement, :expensive, menu: menu, menu_item: menu_item)
      end
    end

    trait :empty do
      # Menu without items
    end

    # Factory variations
    factory :breakfast_menu, traits: [:breakfast]
    factory :lunch_menu, traits: [:lunch]
    factory :dinner_menu, traits: [:dinner]
    factory :menu_with_items, traits: [:with_items]
  end
end
