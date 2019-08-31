class CreateTimers < ActiveRecord::Migration[5.2]
  def change
    create_table :timers do |t|

      t.timestamps
    end
  end
end
