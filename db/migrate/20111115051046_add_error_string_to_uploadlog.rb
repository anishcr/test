class AddErrorStringToUploadlog < ActiveRecord::Migration
  def change
    add_column :uploadlogs, :error_string, :string, :length => 255
  end
end
