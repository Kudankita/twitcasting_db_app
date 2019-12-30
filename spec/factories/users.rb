# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    id { 1 }
    user_id { '182224938' }
    screen_id { 'twitcasting_jp' }
    name { 'ツイキャス公式' }
    is_recordable { true }
    is_deleted { false }

    factory :user2, class: 'User' do
      id { 2 }
      screen_id { 'switcasting_jp' }
      name { 'ツイキャス公式2' }
    end

    factory :user3, class: 'User' do
      id { 3 }
      screen_id { 'uwitcasting_jp' }
      name { 'ツイキャス公式3' }
    end

    factory :record_false_user, class: 'User' do
      is_recordable { false }
    end

    factory :user_with_colon, class: 'User' do
      screen_id { 'twitcasting:jp' }
    end
  end

  factory :not_found_user, class: 'User' do
    user_id { '1' }
    screen_id { 'not_found' }
  end
end
