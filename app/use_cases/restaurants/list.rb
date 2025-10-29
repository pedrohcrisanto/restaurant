# frozen_string_literal: true

module Restaurants
  class List < Micro::Case
    attributes :repo

    def call!
      relation = repo.relation_for_index
      Success result: { relation: relation }
    end
  end
end

