# frozen_string_literal: true

FactoryBot.define do
  factory :menu do
    association :restaurant
    name { %w[lunch dinner breakfast].sample + " #{Faker::Lorem.unique.word}" }
  end
end

