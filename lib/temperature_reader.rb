# -*- encoding : utf-8 -*-
require File.dirname(__FILE__)+'/temperature_reading.rb'
require File.dirname(__FILE__)+'/scl'
require 'serialport'

class TemperatureReader
  ADDRESS=0
  NO_VALUE="#"

  DEVICE_TYPES={
    0 => 'MTR260',
    2 => 'MTR262',
    4 => 'MTR264',
    5 => 'MTR265',
    6 => 'MTR165',
    7 => 'FTR860',
    8 => 'CSR264S',
    9 => 'CSR264L',
    10 => 'CSR264A',
    11 => 'CSR260',
    12 => 'KMR260'
  }

  FLOW_CONTROL_MAP={
    "hard" => 1,
    "soft" => 2,
    "none" => 0
  }

  def initialize(config, logger)
    @logger = logger
    @sport = SerialPort.new config["device"], config["baud"]||9600, config["bits"]||8, config["stopbits"]||1, SerialPort::NONE
    @sport.flow_control=FLOW_CONTROL_MAP[(config["flowcontrol"]||"").downcase] || FLOW_CONTROL_MAP["none"]

    @sport.extend Scl
  end

  def close
    @sport.close
  end

  def next
    @sport.scl_command("DBG 1 ?", ADDRESS)
    response = @sport.scl_response
    if response[0] != NO_VALUE
      split = response.split(" ")
      if (split[0]=='0') 
        dev_type = split[0].to_i
        voltage = (split[1].to_i & 31) / 10.0
        signal_strength = (split[2].to_i & 127) - 127
        id = split[3]
        temperature = (split[4].to_i + split[5].to_i * 256)/10.0 - 273.2;
        time = Time.now
        @logger.debug "#{time}: Device #{id}, Device Type #{DEVICE_TYPES[dev_type]}, Signal strength #{signal_strength}dBm, voltage: #{voltage}V, temperature: #{temperature.round(2)}°C"
        return TemperatureReading.new(id, temperature, voltage, signal_strength, time.to_i)
      end
    end

    nil
  end
end
