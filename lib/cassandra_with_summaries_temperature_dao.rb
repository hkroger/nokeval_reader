# -*- encoding : utf-8 -*-
require File.dirname(__FILE__)+'/cassandra_temperature_dao.rb'
require 'time'

class CassandraWithSummariesTemperatureDAO < CassandraTemperatureDAO
  alias_method :old_store, :store

  def store(reading)
    old_store(reading)

    ts = reading.timestamp || Time.now 
    year_month = to_year_month(ts)
    hour = to_hour_stamp(ts)
    day = to_day_stamp(ts)
    update_stats(reading, ts)
    tmp_in_cents = (reading.temperature * 100).round
    @client.execute("UPDATE #{table_name}_hourly_avg SET temperature_count = temperature_count+1, temperature_sum_in_cents = temperature_sum_in_cents + #{tmp_in_cents} WHERE location_id = #{reading.id} AND year_month = '#{year_month}' AND hour = '#{hour}'")
    @client.execute("UPDATE #{table_name}_daily_avg SET temperature_count = temperature_count+1, temperature_sum_in_cents = temperature_sum_in_cents + #{tmp_in_cents} WHERE location_id = #{reading.id} AND year_month = '#{year_month}' AND day = '#{day}'")
    @client.execute("UPDATE #{table_name}_monthly_avg SET temperature_count = temperature_count+1, temperature_sum_in_cents = temperature_sum_in_cents + #{tmp_in_cents} WHERE location_id = #{reading.id} AND year_month = '#{year_month}'")
  end

  def update_min_max(reading, ts, full_table, condition_string, row=nil)
    if row.nil?
      cql = "SELECT min,max from #{full_table} WHERE #{condition_string}"
      row = @client.execute(cql).first
    end
    if row.nil? || row["max"].nil? || row["max"] < reading.temperature
      cql = "UPDATE #{full_table} SET max=#{reading.temperature}, max_at='#{ts_to_cassandra(ts)}' WHERE #{condition_string}"
      @client.execute cql
    end

    if row.nil? || row["min"].nil? || row["min"] > reading.temperature
      cql = "UPDATE #{full_table} SET min=#{reading.temperature}, min_at='#{ts_to_cassandra(ts)}' WHERE #{condition_string}"
      @client.execute cql
    end
  end

  def update_stats(reading, ts)
    stats = @client.execute("SELECT first_read_at, min, max from #{table_name}_stats WHERE location_id = #{reading.id}").first
    update_min_max(reading, ts, "#{table_name}_stats", "location_id = #{reading.id}", stats)
    update_min_max(reading, ts, "#{table_name}_daily_min_max", "location_id = #{reading.id} AND day = '#{to_day_stamp(ts)}'")
    update_min_max(reading, ts, "#{table_name}_monthly_min_max", "location_id = #{reading.id} AND year_month = '#{to_year_month(ts)}'")

    if stats.nil? || stats["first_read_at"].nil? || stats["first_read_at"] > ts
      @client.execute "UPDATE #{table_name}_stats SET first_read_at='#{ts_to_cassandra(ts)}' WHERE location_id = #{reading.id}"
    end

    @client.execute "UPDATE #{table_name}_stats SET current=#{reading.temperature}, last_read_at='#{ts_to_cassandra(ts)}' WHERE location_id = #{reading.id}"
  end

  def ts_to_cassandra(ts)
    ts.strftime('%Y-%m-%d %H:%M:%S')
  end

  def to_hour_stamp(ts)
    ts.strftime('%Y-%m-%d %H:00:00')
  end

  def to_day_stamp(ts)
    ts.strftime('%Y-%m-%d 00:00:00')
  end
end

