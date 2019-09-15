# frozen_string_literal: true

class AddDefaultToUsers2 < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :is_recordable, :boolean, default: true
    change_column :users, :is_deleted, :boolean, default: false
  end
end
