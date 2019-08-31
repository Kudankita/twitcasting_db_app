# frozen_string_literal: true

FactoryBot.define do
  factory :timer do
    id { 1 }
    #updated_at { Time.current - Constants::API_INTERVAL.second * 10 }
    updated_at { Time.current.yesterday }
    #Time.current.yesterday
  end
end
