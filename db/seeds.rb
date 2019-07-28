# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

CSV.foreach('db/developer.csv') do |info|
  Developer.create name: info[0], email: info[1], password: info[2]
end

CSV.foreach('db/users.csv') do |info|
  User.create user_id: info[0], screen_id: info[1], name: info[2], created_at: info[3], updated_at: info[4],
              last_cas: info[5], is_recordable: info[6], is_casting: info[7], comment_count: info[8],
              max_view_count: info[9], current_view_count: info[10], total_view_count: info[11]
end
