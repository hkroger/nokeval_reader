# -*- encoding : utf-8 -*-
require 'cql'
require 'uuidtools'

class CassandraTemperatureDAO < TemperatureDAO
  def initialize(database_config, logger)
    @config = database_config
    @client = Cql::Client.connect(hosts: @config["host"].split(","))
    @client.use(@config['name'])
  end

  def store(reading)
    if reading.timestamp
      id = UUIDTools::UUID.timestamp_create(reading.timestamp).to_s
      year_month = to_year_month(reading.timestamp)
    else
      id = "now()"
      year_month = to_year_month(Time.now)
    end
    
    @client.execute("INSERT INTO #{table_name}(location_id, year_month, id, measurement) values(#{reading.id}, '#{year_month}', #{id}, #{reading.temperature})")
  end

  def to_year_month(timestamp)
    timestamp.strftime("%Y-%m")
  end
end

