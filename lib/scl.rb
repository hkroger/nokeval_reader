# -*- encoding : utf-8 -*-
require 'timeout'

module Scl
  ID=128
  ETX=3.chr
  ACK=6.chr

  @buffer = nil

  def calc_bcc(str)
    checksum = 0
    if str.is_a? String 
      str.each_byte { |i| checksum = checksum ^ i }
      return checksum.chr
    end
    str.each { |i| checksum = checksum ^ i }
    checksum.chr
  end

  def scl_command(cmd, address)
    message = (address + ID).chr + cmd + ETX
    message = message + calc_bcc(message[1,message.length])

    write(message)
    # flush
  end

  def bin_to_hex(s)
    s.each_byte.map { |b| b.to_s(16) }.join(" ")
  end
  
  def scl_response(timeout = 30)
    @buffer = ""
    Timeout::timeout(timeout) do
#      $stdout.puts "reading"
      while true do
#        $stdout.puts "."
        i = read(1)
        @buffer = @buffer + i
#        $stdout.puts @buffer
#        $stdout.puts bin_to_hex(@buffer)

        msg = scl_valid_response(@buffer)

        return msg if msg
      end
    end
  end  

  def scl_valid_response(message)
    if message[0] != ACK
#      $stdout.puts "no ack"
      return
    end
    etx_offset = message.length-2
    if message[etx_offset] != ETX
#      $stdout.puts "no etx"
      return
    end
    bcc_offset = message.length-1
    if message[bcc_offset] != calc_bcc(message[0,message.length-1])
#      $stdout.puts "checksum no match"
      return
    end
    message[1,message.length-2]
  end

  
end

