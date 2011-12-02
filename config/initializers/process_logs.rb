require 'rubygems'
require 'rufus/scheduler'
require 'csv'

def parse_watt_node_log(upload_log, log_str)
  lines = log_str.split("\n")

  lines.each do |line|
    values = line.parse_csv

    watt_node_log = WattNodeLog.new

    if (values.length == 59)
      watt_node_log.serial_num                  = upload_log.serial_number
      watt_node_log.device_num                  = upload_log.modbus_device
      watt_node_log.time_in_utc                 = Time.zone.parse(values[0]).utc
      watt_node_log.original_time_in_utc        = watt_node_log.time_in_utc
      if (watt_node_log.time_in_utc.sec != 0)
        watt_node_log.time_in_utc = watt_node_log.time_in_utc - watt_node_log.time_in_utc.sec.seconds
      end

      watt_node_log.error                       = values[1]
      watt_node_log.low_alarm                   = values[2]
      watt_node_log.high_alarm                  = values[3]
      watt_node_log.energy_sum_kwh              = values[4]
      watt_node_log.energy_pos_sum_kwh          = values[5]
      watt_node_log.energy_sum_nr_kwh           = values[6]
      watt_node_log.energy_pos_sum_nr_kwh       = values[7]
      watt_node_log.power_sum_w                 = values[8]
      watt_node_log.power_a_w                   = values[9]
      watt_node_log.power_b_w                   = values[10]
      watt_node_log.power_c_w                   = values[11]
      watt_node_log.volts_avg_ln_v              = values[12]
      watt_node_log.volts_phase_a_v             = values[13]
      watt_node_log.volts_phase_b_v             = values[14]
      watt_node_log.volts_phase_c_v             = values[15]
      watt_node_log.volts_avg_ll_v              = values[16]
      watt_node_log.volts_ab_v                  = values[17]
      watt_node_log.volts_bc_v                  = values[18]
      watt_node_log.volts_ac_v                  = values[19]
      watt_node_log.frequency_hz                = values[20]
      watt_node_log.energy_phase_a_kwh          = values[21]
      watt_node_log.energy_phase_b_kwh          = values[22]
      watt_node_log.energy_phase_c_kwh          = values[23]
      watt_node_log.energy_pos_phase_a_kwh      = values[24]
      watt_node_log.energy_pos_phase_b_kwh      = values[25]
      watt_node_log.energy_pos_phase_c_kwh      = values[26]
      watt_node_log.energy_neg_sum_kwh          = values[27]
      watt_node_log.energy_neg_sum_nr_kwh       = values[28]
      watt_node_log.energy_neg_a_kwh            = values[29]
      watt_node_log.energy_neg_b_kwh            = values[30]
      watt_node_log.energy_neg_c_kwh            = values[31]
      watt_node_log.energy_reactive_sum_kwh     = values[32]
      watt_node_log.energy_reactive_phase_a_kwh = values[33]
      watt_node_log.energy_reactive_phase_b_kwh = values[34]
      watt_node_log.energy_reactive_phase_c_kwh = values[35]
      watt_node_log.energy_apparent_sum_kwh     = values[36]
      watt_node_log.energy_apparent_phase_a_kwh = values[37]
      watt_node_log.energy_apparent_phase_b_kwh = values[38]
      watt_node_log.energy_apparent_phase_c_kwh = values[39]
      watt_node_log.power_factor_average        = values[40]
      watt_node_log.power_factor_phase_a        = values[41]
      watt_node_log.power_factor_phase_b        = values[42]
      watt_node_log.power_factor_phase_c        = values[43]
      watt_node_log.power_reactive_sum_var      = values[44]
      watt_node_log.power_reactive_phase_a_var  = values[45]
      watt_node_log.power_reactive_phase_b_var  = values[46]
      watt_node_log.power_reactive_phase_c_var  = values[47]
      watt_node_log.power_apparent_sum_va       = values[48]
      watt_node_log.power_apparent_phase_a_va   = values[49]
      watt_node_log.power_apparent_phase_b_va   = values[50]
      watt_node_log.power_apparent_phase_c_va   = values[51]
      watt_node_log.current_phase_a_a           = values[52]
      watt_node_log.current_phase_b_a           = values[53]
      watt_node_log.current_phase_c_a           = values[54]
      watt_node_log.demand_w                    = values[55]
      watt_node_log.demand_min_w                = values[56]
      watt_node_log.demand_max_w                = values[57]
      watt_node_log.demand_apparent_w           = values[58]

      begin
        watt_node_log.save
      rescue Exception => exc
        puts "Exception while saving watt_node_log: #{exc.message}"
      end
    else
      upload_log.error_string = "failed parsing"
      puts "Failed to parse log file : #{upload_log.file_name}, line : #{line}"
    end
  end
  # ToDo store different status as per parse status.
  upload_log.status = 2
  upload_log.save
  puts ""
end

def process_upload_log(upload_log)
  puts "process_upload_log"

  begin
    #First mark the status as processing
    upload_log.status = 1
    upload_log.save

    # first unzip the file and parse it.
    # then update the watt_node_logs
    log_str = ""

    Zlib::GzipReader.open(upload_log.file_name) {|gz|
      log_str = gz.read
    }
    parse_watt_node_log(upload_log, log_str)
  rescue Exception => exc
    puts "Exception while processing file #{upload_log.file_name}. Exception: #{exc.message}"
    upload_log.error_string =  "#{exc.message}"
    upload_log.save
  end

end

def process_logs()
  #get the entries from the uploadlogs table which are yet to be processed
  #for each record, first mark it under process
  #read the file for that record and then update the watt_node_logs with that entry

  devices = Device.find_all_by_dev_class(4020)

  devices.each do |device|
    #find the entries in the uploadlogs for this device
    new_logs = Uploadlog.find_all_by_modbus_device_and_status(device.modbus_device_num, 0)

    new_logs.each do |new_log|
      process_upload_log(new_log)
    end
  end
end

scheduler = Rufus::Scheduler.start_new

scheduler.every("5m") do
  puts "cron job process_logs"
  process_logs()
end
