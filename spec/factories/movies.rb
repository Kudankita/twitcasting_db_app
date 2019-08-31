# frozen_string_literal: true

FactoryBot.define do
  factory :movie do
    id { 538_624_754 }
    user_id { 'MyString' }
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
  end
end
