require 'composite_primary_keys'

class WattNodeLog  < ActiveRecord::Base
  set_primary_keys :serial_num, :device_num, :original_time_in_utc

  def self.get_last_record
    find(:first, :conditions => ["error = 0"], :order => "time_in_utc DESC")
  end

  def self.get_device_energy_sum_kwh(device_number, frm_time, to_time)
    records = WattNodeLog.find(:all, :conditions => ["error = 0 AND device_num=? AND time_in_utc BETWEEN ? and ?", device_number, frm_time, to_time], :order => "time_in_utc DESC")

    return 0.0 if (records.length  < 2);

    return (records[0].energy_sum_kwh - records.last.energy_sum_kwh)
  end

  def self.get_records(device_number, from_date_time, to_date_time)
    ret_val = Hash.new

    records = WattNodeLog.find(:all, :conditions => ["error = 0 AND device_num=? AND time_in_utc BETWEEN ? and ?", device_number, from_date_time, to_date_time])

    records.each do |record|
      ret_val[record.time_in_utc] = record
    end

    return ret_val
  end

  def self.get_power_factor(device_number, from_date_time, to_date_time)
    ret_val = nil

    records = WattNodeLog.find(:all, :conditions => ["error = 0 AND device_num=? AND time_in_utc BETWEEN ? and ?", device_number, from_date_time, to_date_time])

    i = 0.0
    records.each do |record|
      if (ret_val == nil)
        ret_val = record.power_factor_average
      else
        ret_val = ret_val + record.power_factor_average
      end
      i = i + 1.0
    end

    ret_val = (ret_val / i) if (ret_val != nil)

    return ret_val
  end

  def self.get_power_sum_w(device_number, from_date_time, to_date_time)
    ret_val = nil

    records = WattNodeLog.find(:all, :conditions => ["error = 0 AND device_num=? AND time_in_utc BETWEEN ? and ?", device_number, from_date_time, to_date_time])

    records.each do |record|
      if (ret_val == nil)
        ret_val = record.power_sum_w
      else
        ret_val = ret_val + record.power_sum_w
      end
    end

    return ret_val
  end

end