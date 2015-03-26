require 'serialport'
require_relative 'default_serial_port'
require_relative 'arduino/command_set'
require_relative 'arduino/event_machine'
require_relative 'arduino/status'
# Communicate with the arduino using a serial interface
module FB
  class Arduino
    class EmergencyStop < StandardError; end # Not yet used.

    attr_reader :serial_port, :logger, :commands, :queue, :status

    # Initial and provide a serial object, as well as an IO object to send
    # log messages to. Default SerialPort is DefaultSerialPort. Default logger
    # is STDOUT
    def initialize(serial_port = DefaultSerialPort.new, logger = STDOUT)
      @serial_port, @logger, @queue = serial_port, logger, EM::Queue.new
      @commands, @status = FB::ArduinoCommandSet.new(self), FB::Status.new(self)
    end

    # Log to screen/file/IO stream
    def log(message)
      logger.puts(message)
    end

    # Handle incoming text from arduino into pi
    def onmessage(&blk)
      raise 'read() requires a block' unless block_given?
      @queue.pop { |string| blk.call(string) }
    end

    def onclose(&blk)
      @onclose = blk
    end

    # Send outgoing test to arduino from pi
    def write(string)
      serial_port.puts string
      log "SENT #{string}"
    end

    # Handle loss of serial connection
    def disconnect
      log "Connection to device lost"
      @onclose.call if @onclose
    end

    def reconnect
    end
  end
end
