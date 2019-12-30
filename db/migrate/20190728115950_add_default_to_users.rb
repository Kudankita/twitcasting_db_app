# frozen_string_literal: true

class AddDefaultToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :is_compression, from: nil, to: false
  end
end
