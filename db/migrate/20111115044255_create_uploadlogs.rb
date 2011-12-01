class CreateUploadlogs < ActiveRecord::Migration
  def change
    create_table :uploadlogs do |t|
      t.string :remote_ip_add,   :length => 16
      t.string :serial_number,   :length => 16
      t.string :password,        :length => 45
      t.string :loop_name,       :length => 45
      t.string :modbus_ip,       :length => 16
      t.integer :modbus_port
      t.integer :modbus_device
      t.string :modbus_device_name, :length => 45
      t.string :modbus_device_type_number, :length => 10
      t.string :modbus_device_class, :length => 10
      t.string :md5_checksum, :length => 32
      t.integer :status
      t.string  :file_name, :length => 255
      t.timestamp :file_time
      t.integer :file_size

      t.timestamps
    end
  end
end
