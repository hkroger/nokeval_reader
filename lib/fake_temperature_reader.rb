# -*- encoding : utf-8 -*-
require File.dirname(__FILE__)+'/temperature_reading.rb'
require File.dirname(__FILE__)+'/scl'
require 'serialport'

class FakeTemperatureReader
  def close
  end

  def next
    TemperatureReading.new(1, 20+(rand*10), 4.5+rand, -70+(rand*10), Time.now.to_i) if rand > 0.8
  end
end
