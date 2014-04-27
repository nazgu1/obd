module OBD
  class Command

    def initialize

    end

    def self.format_result command, result
      if is_command?(command) && result != "NO DATA"
        return pids[command.to_sym].call h(result), h(result).to_i(16)
      else
        return result
      end
    end

    def self.to_hex command
      if is_command? command
        "01%02x" % pids.keys.index(command.to_sym)
      else
        command
      end
    end

    def self.is_command? command
      pids.keys.include? command.to_sym
    end

    def self.pid
      {
        "atrv" => [:battery_voltage, lambda {|x| x.to_s}],
        "0100" => [:pids_supported_1]
      }
    end

    def self.pids
      {
        pids_supported_1:                      lambda {|x,d| d.to_s(2).split('').each_with_index.map{|b,i| pids.keys[i] if b == '1'}},
        monitor_status_since_clear:            lambda {|x| x},
        freeze_dtc:                            lambda {|x| x},
        fuel_system_status:                    lambda {|x| x},
        calculated_engine_load:                lambda {|x,d| "%0.2f" % (d * 100.0 / 255.0)},
        engine_coolent_temperature:            lambda {|x,d| "%0.2f" % (d - 40.0)},
        short_term_fuel_trim_bank_1:           lambda {|x,d| "%0.2f" % (d * 0.78125 - 100)},
        long_term_fuel_trim_bank_1:            lambda {|x,d| "%0.2f" % (d * 0.78125 - 100)},
        short_term_fuel_trim_bank_2:           lambda {|x,d| "%0.2f" % (d * 0.78125 - 100)},
        long_term_fuel_trim_bank_2:            lambda {|x,d| "%0.2f" % (d * 0.78125 - 100)},
        fuel_pressure:                         lambda {|x,d| "%0.2f" % (d * 3 * 0.145)},
        intake_manifold_absolute_pressure:     lambda {|x,d| "%0.2f" % (d * 0.145)},
        engine_rpm:                            lambda {|x,d| "%0.2f" % (d / 4.0)},
        vehicle_speed:                         lambda {|x,d| "%0.2f" % (d)},
        timing_advance:                        lambda {|x,d| "%0.2f" % (d / 2.0 - 64)},
        intake_air_temperature:                lambda {|x,d| "%0.2f" % (d - 40)},
        maf_air_flow_rate:                     lambda {|x,d| "%0.2f" % (d / 100.0)},
        throttle_position:                     lambda {|x,d| "%0.2f" % (d * 100 / 255.0)},
        commanded_secondary_air_status:        lambda {|x| x}, # bit encoded
        oxygen_sensors_present:                lambda {|x| x}, # [A0..A3] == Bank 1,Sensors 1-4.[A4..A7]
        bank_1_sensor_1_oxygen_sensor_voltage: lambda {|x| x},
        bank_1_sensor_2_oxygen_sensor_voltage: lambda {|x| x},
        bank_1_sensor_3_oxygen_sensor_voltage: lambda {|x| x},
        bank_1_sensor_4_oxygen_sensor_voltage: lambda {|x| x},
        bank_2_sensor_1_oxygen_sensor_voltage: lambda {|x| x},
        bank_2_sensor_2_oxygen_sensor_voltage: lambda {|x| x},
        bank_2_sensor_3_oxygen_sensor_voltage: lambda {|x| x},
        bank_2_sensor_4_oxygen_sensor_voltage: lambda {|x| x},
        obd_standards_vehicle_conforms_to:     lambda {|x| x}, # bit encoded
        oxygen_sensors_present_2:              lambda {|x| x}, # complicated...
        aux_input_status:                      lambda {|x| (x == 1).inspect}, # Power Take Off (PTO) status is active?
        run_time_since_engine_start:           lambda {|x,d| d}, # seconds
        pids_supported_2:                      lambda {|x,d| d.to_s(2).split('').each_with_index.map{|b,i| pids.keys[i+33] if b == '1'}}, # bit encoded
        distance_traveled_with_mil_on:         lambda {|x,d| d.to_s + 'km'}
      }
    end

    def self.h response
      response[4..-1]
    end


  end
end
