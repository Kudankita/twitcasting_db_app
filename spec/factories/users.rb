FactoryBot.define do
  factory :user do
    screen_id { 'twitcasting_jp' }
  end

  factory :not_found_user, class: 'User' do
    screen_id { 'not_found' }
  end
end
