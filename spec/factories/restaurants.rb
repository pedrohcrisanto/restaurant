# frozen_string_literal: true

FactoryBot.define do
  factory :restaurant do
    name { Faker::Restaurant.name }
  end
end

