class ChangeColumnOnUser < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :user_id, false
    change_column_null :users, :screen_id, false
    change_column_null :users, :name, false
  end
end
