# frozen_string_literal: true

class CreateTimers < ActiveRecord::Migration[5.2]
  def change
    create_table :timers, &:timestamps
  end
end
