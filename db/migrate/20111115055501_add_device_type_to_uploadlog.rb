class AddDeviceTypeToUploadlog < ActiveRecord::Migration
  def change
    add_column :uploadlogs, :device_type, :string, :length => 255
  end
end
