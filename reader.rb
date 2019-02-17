#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'logger'
require File.dirname(__FILE__)+'/lib/temperature_reader.rb'
require File.dirname(__FILE__)+'/lib/fake_temperature_reader.rb'
require File.dirname(__FILE__)+'/lib/temperature_dao.rb'
require File.dirname(__FILE__)+'/lib/measurement_buffer.rb'

STDOUT.sync = true

logger = Logger.new(STDOUT)
config = YAML.load(File.read(File.dirname($0)+"/config.yaml"))
dao = TemperatureDAO.factory(config['database'], logger)
buffer = MeasurementBuffer.new(config['buffer_file'], logger)

puts "Starting reading at #{Time.now}"
begin
  if config['fake_reader_mode'] == true
    temp_reader = FakeTemperatureReader.new
  else
    temp_reader = TemperatureReader.new(config["serial"], logger)
  end

  begin
    begin 
      reading = temp_reader.next
      if reading and reading.valid?
        if config['fake_storage_mode'] == true
          puts "fake storage mode: " + reading.inspect
        else 
          buffer.store(reading) 
        end
      end
    end while reading
    if config['fake_storage_mode'] != true
      buffer.flush(dao) 
    end
    sleep 5
  end while true
rescue RuntimeError, SocketError, SystemCallError => e
  logger.warn "Error during processing: #{$!}"
  logger.debug "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
  if temp_reader.nil?
    logger.warn "Reader device could not be initialized. Waiting for 5 seconds."
    sleep 5
  else
    temp_reader.close
    temp_reader = nil
  end
end while true
