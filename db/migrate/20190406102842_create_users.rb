# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :user_id
      t.string :screen_id
      t.string :name
      t.string :last_cas
      t.boolean :is_recordable
      t.boolean :is_casting
      t.integer :comment_count
      t.integer :max_view_count
      t.integer :current_view_count
      t.integer :total_view_count
      t.text :remark
      t.boolean :is_compression
      t.boolean :is_deleted

      t.timestamps
    end
  end
end
