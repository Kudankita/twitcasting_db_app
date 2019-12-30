# frozen_string_literal: true

class AddRememberDigestToDevelopers < ActiveRecord::Migration[5.2]
  def change
    add_column :developers, :remember_digest, :string
  end
end
