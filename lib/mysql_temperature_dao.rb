# -*- encoding : utf-8 -*-
require 'mysql2'

class MysqlTemperatureDAO < TemperatureDAO
  def initialize(database_config, logger)
    @config = database_config
    @client = Mysql2::Client.new(
      :host => @config["hostname"],
      :username => @config["username"],
      :database => @config["name"],
      :password => @config["password"],
      :encoding => "utf8",
      :reconnect => true
    )
  end

  def store(reading)
      @client.query("INSERT INTO #{table_name}(location_id, measurement) values(#{reading.id},#{reading.temperature})")
  end
end


