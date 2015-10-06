# -*- encoding : utf-8 -*-
class TemperatureDAO
  def initialize
    raise "You can't instantiate me. Use TemperatureDAO.factory(config), please."
  end

  def self.factory(database_config, logger)
    case database_config['type']
    when 'mysql'
      require File.dirname(__FILE__)+'/mysql_temperature_dao.rb'
      return MysqlTemperatureDAO.new(database_config, logger)
    when 'cassandra'
      require File.dirname(__FILE__)+'/cassandra_temperature_dao.rb'
      return CassandraTemperatureDAO.new(database_config, logger)
    when 'cassandra_with_summaries'
      require File.dirname(__FILE__)+'/cassandra_with_summaries_temperature_dao.rb'
      return CassandraWithSummariesTemperatureDAO.new(database_config, logger)
    when 'rest_storage'
      require File.dirname(__FILE__)+'/rest_storage_dao.rb'
      return RestStorageDao.new(database_config, logger)
    end
  end

  def table_name
    @config['table_name']
  end
end

