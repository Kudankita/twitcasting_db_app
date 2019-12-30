# frozen_string_literal: true

FactoryBot.define do
  factory :timer do
    id { 1 }
    updated_at { Time.current.yesterday }
  end
end
