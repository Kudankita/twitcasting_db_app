class AddIndexToUsersEmail < ActiveRecord::Migration[5.2]
  def change
    add_index :developers, :email, unique: true
  end
end
