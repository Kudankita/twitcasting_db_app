# frozen_string_literal: true

class User < ApplicationRecord
  validates :screen_id, presence: true, uniqueness: true
end
