# -*- encoding : utf-8 -*-
class TemperatureReading
  attr :id
  attr :temperature
  attr :timestamp
  attr :voltage
  attr :signal_strength

  def valid?
    return false if @temperature.nil?
    return false if @temperature < -200
    return false if @temperature > 140
    true
  end

  def initialize(id, temperature, voltage, signal_strength, timestamp)
    @id = id
    @temperature = temperature
    @voltage= voltage
    @signal_strength = signal_strength
    @timestamp = timestamp
  end
end
