# -*- encoding : utf-8 -*-
require 'rest-client'
require 'digest/sha1'

class RestStorageDao < TemperatureDAO
  def initialize(database_config, logger)
    @config = database_config
    @logger = logger
    urls = @config['url']
    @config['url'] = [urls] unless urls.is_a? Array 
  end

  def store(reading)
    content = {
      'client_id' => @config['client_id'],
      'timestamp' => reading.timestamp.to_s,
      'sensor_id' => reading.id.to_s,
      'measurement' => reading.temperature.to_s,
      'voltage' => reading.voltage.to_s,
      'signal_strength' => reading.signal_strength.to_s,
      'version' => 2
    }
    content['checksum'] = generate_checksum(content, @config['key'])
    @config['url'].each do |url|
      begin 
        RestClient.post(url, content.to_json, :content_type => :json, :accept => :json)
        @logger.debug "Measurement stored in #{url} successfully"
        return true
      rescue Errno::ECONNREFUSED => e
        @logger.debug "Errno::ECONNREFUSED: #{e.message}"
      rescue RestClient::ExceptionWithResponse => e
        @logger.debug "Exception: #{e.message}"
        @logger.debug "Response: #{e.response}"
        if e.http_code == 403
          @logger.debug "Got 403, we are not authorized. Let's skip this."
          return true
        end
        return false if !e.http_code.nil? and e.http_code >= 400 and e.http_code < 500
      rescue RestClient::Exception => e
        @logger.debug "Exception: #{e.message}"
      end
    end
    @logger.debug "Failed to store measurement: #{reading.inspect}"
    false
  end

  private
  def generate_checksum(hsh, secret)
    string = "#{hsh['version']}&#{hsh['timestamp']}&#{hsh['voltage']}&#{hsh['signal_strength']}&#{hsh['client_id']}&#{hsh['sensor_id']}&#{hsh['measurement']}&#{secret}"
    Digest::SHA1.hexdigest(string)
  end
end



