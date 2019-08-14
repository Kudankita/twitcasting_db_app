class CreateMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :movies, id: false do |t|
      t.column :id, 'INTEGER PRIMARY KEY NOT NULL'
      t.string :user_id
      t.string :title
      t.string :subtitle
      t.string :last_owner_comment
      t.string :category
      t.string :link
      t.boolean :is_live
      t.boolean :is_recorded
      t.integer :comment_count
      t.string :large_thumbnail
      t.string :small_thumbnail
      t.string :country
      t.integer :duration
      t.integer :created
      t.boolean :is_collabo
      t.boolean :is_protected
      t.integer :max_view_count
      t.integer :current_view_count
      t.integer :total_view_count
      t.string :hls_url

      t.timestamps
    end
  end
end
