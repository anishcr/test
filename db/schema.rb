# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111115055501) do

  create_table "devices", :force => true do |t|
    t.integer  "modbus_device_num"
    t.integer  "dev_class"
    t.string   "name"
    t.string   "manifest_file_name", :limit => 1024
    t.string   "manifest_crc"
    t.datetime "manifest_timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.integer  "device_id"
    t.date     "date"
    t.integer  "power"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uploadlogs", :force => true do |t|
    t.string   "remote_ip_add"
    t.string   "serial_number"
    t.string   "password"
    t.string   "loop_name"
    t.string   "modbus_ip"
    t.integer  "modbus_port"
    t.integer  "modbus_device"
    t.string   "modbus_device_name"
    t.string   "modbus_device_type_number"
    t.string   "modbus_device_class"
    t.string   "md5_checksum"
    t.integer  "status"
    t.string   "file_name"
    t.datetime "file_time"
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "error_string"
    t.string   "device_type"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "watt_node_logs", :id => false, :force => true do |t|
    t.string    "serial_num",                  :limit => 64,                                :null => false
    t.integer   "device_num",                                                               :null => false
    t.timestamp "time_in_utc",                                                              :null => false
    t.integer   "error",                                                                    :null => false
    t.decimal   "low_alarm",                                 :precision => 12, :scale => 4
    t.decimal   "high_alarm",                                :precision => 12, :scale => 4
    t.decimal   "energy_sum_kwh",                            :precision => 12, :scale => 4
    t.decimal   "energy_pos_sum_kwh",                        :precision => 12, :scale => 4
    t.decimal   "energy_sum_nr_kwh",                         :precision => 12, :scale => 4
    t.decimal   "energy_pos_sum_nr_kwh",                     :precision => 12, :scale => 4
    t.decimal   "power_sum_w",                               :precision => 12, :scale => 4
    t.decimal   "power_a_w",                                 :precision => 12, :scale => 4
    t.decimal   "power_b_w",                                 :precision => 12, :scale => 4
    t.decimal   "power_c_w",                                 :precision => 12, :scale => 4
    t.decimal   "volts_avg_ln_v",                            :precision => 12, :scale => 4
    t.decimal   "volts_phase_a_v",                           :precision => 12, :scale => 4
    t.decimal   "volts_phase_b_v",                           :precision => 12, :scale => 4
    t.decimal   "volts_phase_c_v",                           :precision => 12, :scale => 4
    t.decimal   "volts_avg_ll_v",                            :precision => 12, :scale => 4
    t.decimal   "volts_ab_v",                                :precision => 12, :scale => 4
    t.decimal   "volts_bc_v",                                :precision => 12, :scale => 4
    t.decimal   "volts_ac_v",                                :precision => 12, :scale => 4
    t.decimal   "frequency_hz",                              :precision => 12, :scale => 4
    t.decimal   "energy_phase_a_kwh",                        :precision => 12, :scale => 4
    t.decimal   "energy_phase_b_kwh",                        :precision => 12, :scale => 4
    t.decimal   "energy_phase_c_kwh",                        :precision => 12, :scale => 4
    t.decimal   "energy_pos_phase_a_kwh",                    :precision => 12, :scale => 4
    t.decimal   "energy_pos_phase_b_kwh",                    :precision => 12, :scale => 4
    t.decimal   "energy_pos_phase_c_kwh",                    :precision => 12, :scale => 4
    t.decimal   "energy_neg_sum_kwh",                        :precision => 12, :scale => 4
    t.decimal   "energy_neg_sum_nr_kwh",                     :precision => 12, :scale => 4
    t.decimal   "energy_neg_a_kwh",                          :precision => 12, :scale => 4
    t.decimal   "energy_neg_b_kwh",                          :precision => 12, :scale => 4
    t.decimal   "energy_neg_c_kwh",                          :precision => 12, :scale => 4
    t.decimal   "energy_reactive_sum_kwh",                   :precision => 12, :scale => 4
    t.decimal   "energy_reactive_phase_a_kwh",               :precision => 12, :scale => 4
    t.decimal   "energy_reactive_phase_b_kwh",               :precision => 12, :scale => 4
    t.decimal   "energy_reactive_phase_c_kwh",               :precision => 12, :scale => 4
    t.decimal   "energy_apparent_sum_kwh",                   :precision => 12, :scale => 4
    t.decimal   "energy_apparent_phase_a_kwh",               :precision => 12, :scale => 4
    t.decimal   "energy_apparent_phase_b_kwh",               :precision => 12, :scale => 4
    t.decimal   "energy_apparent_phase_c_kwh",               :precision => 12, :scale => 4
    t.decimal   "power_factor_average",                      :precision => 12, :scale => 4
    t.decimal   "power_factor_phase_a",                      :precision => 12, :scale => 4
    t.decimal   "power_factor_phase_b",                      :precision => 12, :scale => 4
    t.decimal   "power_factor_phase_c",                      :precision => 12, :scale => 4
    t.decimal   "power_reactive_sum_var",                    :precision => 12, :scale => 4
    t.decimal   "power_reactive_phase_a_var",                :precision => 12, :scale => 4
    t.decimal   "power_reactive_phase_b_var",                :precision => 12, :scale => 4
    t.decimal   "power_reactive_phase_c_var",                :precision => 12, :scale => 4
    t.decimal   "power_apparent_sum_va",                     :precision => 12, :scale => 4
    t.decimal   "power_apparent_phase_a_va",                 :precision => 12, :scale => 4
    t.decimal   "power_apparent_phase_b_va",                 :precision => 12, :scale => 4
    t.decimal   "power_apparent_phase_c_va",                 :precision => 12, :scale => 4
    t.decimal   "current_phase_a_a",                         :precision => 12, :scale => 4
    t.decimal   "current_phase_b_a",                         :precision => 12, :scale => 4
    t.decimal   "current_phase_c_a",                         :precision => 12, :scale => 4
    t.decimal   "demand_w",                                  :precision => 12, :scale => 4
    t.decimal   "demand_min_w",                              :precision => 12, :scale => 4
    t.decimal   "demand_max_w",                              :precision => 12, :scale => 4
    t.decimal   "demand_apparent_w",                         :precision => 12, :scale => 4
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

end
