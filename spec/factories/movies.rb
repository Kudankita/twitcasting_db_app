# frozen_string_literal: true

FactoryBot.define do
  factory :movie do
    id { 189_037_369 }
    user_id { '182224938' }
    title { 'MyString' }
    subtitle { 'MyString' }
    last_owner_comment { 'MyString' }
    category { 'MyString' }
    link { 'MyString' }
    is_live { true }
    is_recorded { false }
    comment_count { 1 }
    large_thumbnail { 'MyString' }
    small_thumbnail { 'MyString' }
    country { 'MyString' }
    duration { 1 }
    created { 1 }
    is_collabo { false }
    is_protected { false }
    max_view_count { 1 }
    current_view_count { 1 }
    total_view_count { 1 }
    hls_url { 1 }
    created_at { '2016-05-29 00:50:00' }
    updated_at { '2016-05-29 00:55:00' }
    factory :movie2, class: 'Movie' do
      id { 189_037_370 }
      title { 'NewerMyString' }
      updated_at { '2016-05-29 00:56:00' }
    end
  end
end
