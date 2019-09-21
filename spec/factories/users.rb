FactoryBot.define do
  factory :user do
    id { 1 }
    user_id { '182224938' }
    screen_id { 'twitcasting_jp' }
    name { 'ツイキャス公式' }
    is_recordable { true }
    is_deleted { false }
  end

  factory :not_found_user, class: 'User' do
    screen_id { 'not_found' }
  end

  factory :record_false_user, class: 'User' do
    id { 1 }
    user_id { '182224938' }
    screen_id { 'twitcasting_jp' }
    name { 'ツイキャス公式' }
    is_recordable { false }
    is_deleted { false }
  end
end
