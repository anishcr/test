class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :device_id
      t.date :date
      t.integer :power

      t.timestamps
    end
  end
end
