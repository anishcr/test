class Device < ActiveRecord::Base
  def get_manifest_crc()
    (self.manifest_crc == nil) ? '' : self.manifest_crc
  end
  def get_manifest_timestamp()
    (self.manifest_timestamp == nil) ? '' : self.manifest_timestamp
  end
end
