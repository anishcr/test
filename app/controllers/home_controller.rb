require 'time'
require "zlib"
require 'iconv'

class HomeController < ApplicationController
  BOM = "\377\376" #Byte Order Mark

  def login
    if request.post?
      email    = params[:email]
      password = params[:password]

      if ((email == nil) || (password == nil) || email.empty? || password.empty?)
        flash[:alert] = 'Both email and password are mandatory'
        return
      end
      users_list = User.find_user(email, password)

      if ((users_list != nil) && (users_list.length() != 0))
        #render :text => "successful login"
        session[:user_id] = users_list[0].id
        redirect_to :action => 'charts'
        return
      end
      flash[:alert] = 'Incorrect email and/or password'
    end
  end

  def logout
    user = User.find_by_id(session[:user_id])

    session[:user_id] = nil

    if (user == nil)
      flash[:alert] = 'Please login'
    else
      flash[:alert] = 'Logged out successfully'
    end
    redirect_to :action => 'login'
  end

  def dashboard
    user = User.find_by_id(session[:user_id])

    if (user == nil)
      redirect_to :action => 'login'
    end
  end

  def get_report_data
    tz = Time.zone
    Time.zone = 'Central Time (US & Canada)'

    @to_datetime_cst   = Time.zone.local(@to_date.year, @to_date.month, @to_date.day, 0, 0, 0) + 1.day
    @from_datetime_cst = Time.zone.local(@from_date.year, @from_date.month, @from_date.day, 0, 0, 0)

    Time.zone = tz

    @to_datetime_utc   = @to_datetime_cst.utc
    @from_datetime_utc = @from_datetime_cst.utc

    @interval = 1 # day

    @pwr_demand_day_map = Hash.new

    @last_day_time = Array.new

    first_time = true
    @selected_devices.each do |device|
      device_pwr_map = Hash.new

      time_utc = @from_datetime_utc
      time_cst = @from_datetime_cst

      frm_time_utc = time_utc

      while (frm_time_utc < @to_datetime_utc)
        @last_day_time.push(time_cst) if (first_time == true)

        to_time_utc = time_utc + @interval.days

        device_pwr_map[time_cst] = WattNodeLog.get_device_energy_sum_kwh(device.modbus_device_num, frm_time_utc, to_time_utc)

        time_utc     = time_utc + @interval.days
        time_cst     = time_cst + @interval.days
        frm_time_utc = frm_time_utc + @interval.days
      end
      @pwr_demand_day_map[device.id] = device_pwr_map
      first_time = false
    end
  end

  def energy_report()
    user = User.find_by_id(session[:user_id])

     if (user == nil)
       redirect_to :action => 'login'
       return
     end
     @user_name = user.name

     @devices = Array.new
     @devices[0] = Device.find_by_modbus_device_num(3)
     @devices[1] = Device.find_by_modbus_device_num(7)

     if (params[:devices] != nil)
       devices = params[:devices]
       tmp_frm_date = params[:from_date].split("/")
       tmp_to_date  = params[:to_date].split("/")

       @from_date = Date.new(tmp_frm_date[2].to_i, tmp_frm_date[0].to_i, tmp_frm_date[1].to_i)
       @to_date   = Date.new(tmp_to_date[2].to_i, tmp_to_date[0].to_i, tmp_to_date[1].to_i)

       if (devices.length == 0)
         flash[:alert] = "Please select device(s)"
       else
         @selected_devices    = Array.new
         @selected_device_num = Array.new

         devices.each do |modbus_device_num|
           @selected_device_num.push(modbus_device_num.to_i)
           @selected_devices.push(Device.find_by_modbus_device_num(modbus_device_num.to_i))
         end
       end
     else
       @num_days = 7
       @to_datetime_utc = WattNodeLog.get_last_record.time_in_utc
       @to_datetime_cst = @to_datetime_utc.in_time_zone('Central Time (US & Canada)')

       @to_date   = @to_datetime_cst.to_date
       @from_date = @to_date - @num_days + 1

       @selected_devices    = Array.new
       @selected_device_num = Array.new

       @devices.each do |d|
         @selected_device_num.push(d.modbus_device_num)
         @selected_devices.push(d)
       end
     end
     get_report_data()
  end

  def export
    energy_report()
    return export_csv(@selected_devices, @last_day_time, @pwr_demand_day_map)
  end

  def run_report
    energy_report()
  end

  def get_data(user)
    @user_name = user.name

    @devices = Array.new
    @devices[0] = Device.find_by_modbus_device_num(3)
    @devices[1] = Device.find_by_modbus_device_num(7)

    @num_days = 6
    @to_datetime_utc = WattNodeLog.get_last_record.time_in_utc

    @to_datetime_cst = @to_datetime_utc.in_time_zone('Central Time (US & Canada)')

    @to_date_cst   = @to_datetime_cst.to_date
    @from_date_cst = @to_datetime_cst - @num_days

    @energy_sum_kwh_24_hour_map = Hash.new

    tz = Time.zone
    Time.zone = 'Central Time (US & Canada)'

    @to_datetime_7_day_cst   = Time.zone.local(@to_date_cst.year, @to_date_cst.month, @to_date_cst.day, 0, 0, 0)
    @from_datetime_7_day_cst = @to_datetime_7_day_cst - @num_days.days

    Time.zone = tz

    @to_datetime_7_day_utc   = @to_datetime_7_day_cst.utc
    @from_datetime_7_day_utc = @from_datetime_7_day_cst.utc

    @interval_7_day = 1 # day
    @num_7_day_rows = 0

    @pwr_demand_7_day_map         = Hash.new
    @energy_consumption_7_day_map = Hash.new

    @last_7_day_time = Array.new

    first_time = true
    @devices.each do |device|
      device_pwr_map    = Hash.new
      device_energy_map = Hash.new

      time_utc = @from_datetime_7_day_utc
      time_cst = @from_datetime_7_day_cst

      frm_time_utc = time_utc + 1.seconds

      while (time_utc <= @to_datetime_7_day_utc)
        to_time_utc = time_utc + @interval_7_day.days

        if (first_time == true)
          @last_7_day_time.push(time_cst)
          @num_7_day_rows = @num_7_day_rows + 1
        end

        device_energy_map[time_cst] = WattNodeLog.get_device_energy_sum_kwh(device.modbus_device_num, frm_time_utc - 1.seconds, to_time_utc)
        device_pwr_map[time_cst]    = WattNodeLog.get_power_sum_w(device.modbus_device_num, frm_time_utc, to_time_utc)

        time_utc     = time_utc + @interval_7_day.days
        time_cst     = time_cst + @interval_7_day.days
        frm_time_utc = frm_time_utc + @interval_7_day.days
      end
      @pwr_demand_7_day_map[device.id]         = device_pwr_map
      @energy_consumption_7_day_map[device.id] = device_energy_map
      first_time = false
    end

    @to_datetime_24_hour_utc   = @to_datetime_utc
    @from_datetime_24_hour_utc = @to_datetime_24_hour_utc - 24.hours
    @from_datetime_24_hour_cst = @to_datetime_cst - 24.hours

    @interval_24_hour      = 60 # minutes
    @watt_node_records_map = Hash.new

    @pf_map                         = Hash.new
    @pwr_demand_24_hour_map         = Hash.new
    @energy_consumption_24_hour_map = Hash.new

    @last_24_hour_time = Array.new
    @num_24_hour_rows = 0

    first_time = true

    @devices.each do |device|
      device_pf_map  = Hash.new
      device_pwr_map = Hash.new

      time_utc = @from_datetime_24_hour_utc - @interval_24_hour.minutes
      time_cst = @from_datetime_24_hour_cst - @interval_24_hour.minutes

      frm_time_utc = time_utc + 1.seconds

      @energy_consumption_24_hour_map[device.id] = WattNodeLog.get_device_energy_sum_kwh(device.modbus_device_num, @from_datetime_24_hour_utc, @to_datetime_utc)

      while (time_utc < @to_datetime_24_hour_utc)
        to_time_utc = time_utc + @interval_24_hour.minutes
        to_time_cst = time_cst + @interval_24_hour.minutes

        if (first_time == true)
          @last_24_hour_time.push(to_time_cst)
          @num_24_hour_rows = @num_24_hour_rows + 1
        end

        device_pwr_map[to_time_cst] = WattNodeLog.get_power_sum_w(device.modbus_device_num, frm_time_utc, to_time_utc)
        device_pf_map[to_time_cst] = WattNodeLog.get_power_factor(device.modbus_device_num, frm_time_utc, to_time_utc)

        time_utc  = time_utc + @interval_24_hour.minutes
        time_cst  = time_cst + @interval_24_hour.minutes
        frm_time_utc = frm_time_utc + @interval_24_hour.minutes
      end
      @pf_map[device.id] = device_pf_map
      @pwr_demand_24_hour_map[device.id] = device_pwr_map
      first_time = false
    end

    @display_from_to = "(from #{@from_datetime_24_hour_cst.strftime("%a %H:%M%p")} to #{@to_datetime_cst.strftime("%a %H:%M%p")})"
  end

  def charts
    user = User.find_by_id(session[:user_id])

    if (user == nil)
      redirect_to :action => 'login'
      return
    end

    get_data(user)

    @display_energy = true
    @display_power_factor = true
    @display_power_demand = true

  end

  def energy
    user = User.find_by_id(session[:user_id])

    if (user == nil)
      redirect_to :action => 'login'
    else
      get_data(user)
      @display_energy = true
      render :action => 'charts'
    end
  end
  def power_factor
    user = User.find_by_id(session[:user_id])

    if (user == nil)
      redirect_to :action => 'login'
    else
      get_data(user)
      @display_power_factor = true
      render :action => 'charts'
    end
  end
  def power_demand
    user = User.find_by_id(session[:user_id])

    if (user == nil)
      redirect_to :action => 'login'
    else
      get_data(user)
      @display_power_demand = true
      render :action => 'charts'
    end
  end


  def newdashboard
    user = User.find_by_id(session[:user_id])

    if (user == nil)
      redirect_to :action => 'login'
    end

    @devices = Device.find_all_by_dev_class(4020, :order => "id ASC")

    @num_days = 7
    @to_date   = Log.find(:first, :order => "date DESC").date
    @from_date = @to_date - @num_days + 1

    @value_map = Hash.new
    @latest_power_map = Hash.new

    @devices.each do |device|
      logs = Log.where(:device_id => device.id, :date => @from_date..@to_date)
      logs_map = Hash.new
      logs.each do |log|
        logs_map[log.date] = log.power

        if (log.date == @to_date)
          @latest_power_map[device.id] = log.power
        end
      end
      @value_map[device.id] = logs_map
    end
  end

  def process_status
    if request.post?
      render :inline => "\nSUCCESS\n"
    else
      render :inline => "STATUS /Get"
    end
  end

  def process_manifest
     logger.info "process_manifest called"
#    if request.post?
      @devices = Device.find(:all)
      str = "\n"

      @devices.each do |device|
        str = str + "CONFIGFILE,#{device.manifest_file_name},#{device.get_manifest_crc},#{device.get_manifest_timestamp}\n"
      end
      str = str + "\n"
      render :inline => "#{str}"
#    else
#      render :inline => "CONFIGFILEMANIFEST /Get"
#    end
  end

  def process_configfile_upload
    if ((request.post?) && (params[:CONFIGFILE] != nil))
      file_time         = params[:FILETIME]
      manifest_filename = "modbus/#{name}"

      directory = "public/data"
      name              = params[:CONFIGFILE].original_filename
      crc               = params[:MD5CHECKSUM]
      # create the file path
      path = File.join(directory, name)
      logger.info "#{path}"
      # write the file
      File.open(path, "wb") { |f| f.write(params[:CONFIGFILE].read) }

      device = Device.find_by_manifest_file_name(manifest_filename)

      if (device != nil)
        device.manifest_crc       = crc
        device.manifest_timestamp = file_time
        device.save
      end
      render :inline => "\nSUCCESS\n"
    else
      render :inline => "CONFIGFILEUPLOAD /Get"
    end
  end

  def process_logfile_upload
    logger.info "process_logfile_upload called"

    if ((request.post?) && (params[:LOGFILE] != nil))
      logger.info "process_logfile_upload if part"
      directory = "public/data"
      name =  params[:LOGFILE].original_filename
      # create the file path
      path = File.join(directory, name)
      logger.info "#{path}"
      # write the file
      File.open(path, "wb") { |f| f.write(params[:LOGFILE].read) }

      # Ensure that the crc checksum matches.
      buf = open(path,"rb"){|file| file.read}

      md5 = Digest::MD5.hexdigest buf

      if (md5 == params[:MD5CHECKSUM])
        upload_log = Uploadlog.new

        upload_log.remote_ip_add             = params[:REMOTE_ADDR]
        upload_log.serial_number             = params[:SERIALNUMBER]
        upload_log.password                  = params[:PASSWORD]
        upload_log.loop_name                 = params[:LOOPNAME]
        upload_log.modbus_ip                 = params[:MODBUSIP]
        upload_log.modbus_port               = params[:MODBUSPORT]
        upload_log.modbus_device             = params[:MODBUSDEVICE]
        upload_log.modbus_device_name        = params[:MODBUSDEVICENAME]
        upload_log.modbus_device_type        = params[:MODBUSDEVICETYPE]
        upload_log.modbus_device_type_number = params[:MODBUSDEVICETYPENUMBER]
        upload_log.modbus_device_class       = params[:MODBUSDEVICECLASS]
        upload_log.md5_checksum              = params[:MD5CHECKSUM]
        upload_log.status                    = 0
        upload_log.file_name                 = path
        upload_log.file_time                 = params[:FILETIME]
        upload_log.file_size                 = params[:FILESIZE]

        upload_log.save

        render :inline => "\nSUCCESS\n"
      else
        logger.error "Rejected logfile upload because checksum mismatch"

        render :inline => "\nFAILURE: The calculated checksum of received log file does not match with the form variable.\n",  :status => 403
      end
    else
      logger.info "process_logfile_upload else part"
      render :inline => "LOGFILEUPLOAD /Get"
    end
  end

  def acquisuite
    if request.post?
      mode = params[:MODE]
      logger.info "acquisuite() called with params #{params}"
      params.each do |param|
        logger.info param
      end
      if (mode == nil)
        mode = ""
      end
      logger.info "acquisuite called with MODE : #{mode}"

      if (mode == "STATUS")
        return process_status
      elsif (mode == "CONFIGFILEMANIFEST")
        return process_manifest
      elsif (mode == "CONFIGFILEUPLOAD")
        return process_configfile_upload
      elsif (mode == "LOGFILEUPLOAD")
        return process_logfile_upload
      else
        render :inline => "Unsupported request", :status => 403
      end
      return
    end
  end
protected

  def export_csv(devices, days, pwr_demand_day_map)
    logger.info "export_csv function called"
    filename = "EnergyConsumption.csv"
    content = CSV.generate do |csv|
      csv << ["Date", "Device Name", "Consumption(kWh)", "Cost ($)"]
      total_kwh = nil
      total_cost = nil
      days.each do |day|
        devices.each do |device|
          val = pwr_demand_day_map[device.id][day]
          if (val != nil)
            val_kWh = val
            val_cost = val /10.0
            csv << ["#{day.strftime('%d/%b/%Y')}", device[:name], "#{val_kWh}", "#{val_cost.round(2)}"]

            if (total_kwh == nil)
              total_kwh  = val_kWh
              total_cost = val_cost
            else
              total_kwh  = total_kwh + val_kWh
              total_cost = total_cost + val_cost
            end
          end
        end
      end
      if (total_kwh != nil)
        csv << ["TOTAL", "", "#{total_kwh}", "#{total_cost.round(2)}"]
      end
    end
    #content = BOM + Iconv.conv("utf-16le", "utf-8", content)
    send_data content, :filename => filename, :type => "application/xls"
    logger.info "returning from export_csv function"
  end
end
