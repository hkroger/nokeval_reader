require 'sqlite3'
require 'oj'

class MeasurementBuffer
  def initialize(filename, logger)
    @db = SQLite3::Database.new(filename)
    @logger = logger

    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS measurements(
        id INTEGER PRIMARY KEY ASC,
        json_data TEXT 
      )
    SQL
  end

  def store(measurement)
    @db.execute("INSERT INTO measurements(json_data) VALUES (?)", [Oj.dump(measurement)])
  end

  def remove(id)
    @db.execute("DELETE FROM measurements WHERE id = ?", id)
  end

  def flush(dao)
    @db.execute( "SELECT id, json_data FROM measurements" ) do |row|
      id = row[0]
      json = row[1]
      measurement = Oj.load(json)
      remove(id) if dao.store(measurement)
    end
  end
end
