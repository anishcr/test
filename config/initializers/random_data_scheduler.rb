require 'rubygems'
require 'rufus/scheduler'

def save_log(log, device_id, date, power)
  log.device_id = device_id
  log.date      = date
  log.power     = power
  log.save
end
def create_new_log(device_id, date, max_val, min_val)
  log = Log.new
  save_log(log, device_id, date, (Random.rand(max_val-min_val) + min_val))
end

def update_log(log, max_val, min_val)
  if (log != nil)
    save_log(log, log.device_id, log.date, (log.power + Random.rand(max_val-min_val) + min_val))
  end
end

def check_log(device_id, from_date, to_date)
  update_required = true
  from_date.upto(to_date) do |date|
    log = Log.find_by_device_id_and_date(device_id, date)
    if (log == nil)
      if (date == to_date)
        update_required = false
        create_new_log(device_id, date, 20, 10)
      else
        create_new_log(device_id, date, 700, 120)
      end
    end
  end

  if (update_required == true)
    log = Log.find_by_device_id_and_date(device_id, to_date)
    update_log(log, 5, 2)
  end
end

def update_devices()
  devices = Device.find(:all)

  if devices != nil
    todays_date = Date.today()
    from_date   = todays_date - 7

    devices.each do |device|
      check_log(device.id, from_date, todays_date)
    end
  end
end

#scheduler = Rufus::Scheduler.start_new

#scheduler.every("5m") do
#  update_devices()
#end