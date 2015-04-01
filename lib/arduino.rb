require 'serialport'
require_relative 'default_serial_port'
require_relative 'arduino/incoming_handler'
require_relative 'arduino/outgoing_handler'
require_relative 'arduino/event_machine'
require_relative 'arduino/status'
# Communicate with the arduino using a serial interface
module FB
  class Arduino
    class EmergencyStop < StandardError; end # Not yet used.

    attr_reader :serial_port, :logger, :commands, :queue, :status, :inputs

    # Initialize and provide a serial object, as well as an IO object to send
    # log messages to. Default SerialPort is DefaultSerialPort. Default logger
    # is STDOUT
    def initialize(serial_port = DefaultSerialPort.new, logger = STDOUT)
      @serial_port = serial_port
      @logger      = logger
      @outgoing    = []
      @queue       = EM::Channel.new
      @commands    = FB::OutgoingHandler.new(self)
      @inputs      = FB::IncomingHandler.new(self)
      @status      = FB::Status.new(self)
      status.onchange { |diff| nil }
    end

    # Log to screen/file/IO stream
    def log(message)
      logger.puts(message)
    end

    # Highest priority message when processing incoming Gcode. Use for system
    # level status changes.
    def parse_incoming(gcode)
      inputs.execute(gcode)
    end

    # Handle incoming text from arduino into pi
    def onmessage(&blk)
      raise 'read() requires a block' unless block_given?
      @queue.subscribe do |gcodes|
        gcodes.each do |gcode|
          parse_incoming(gcode)
          blk.call(gcode)
        end
      end
    end

    def onclose(&blk)
      @onclose = blk
    end

    # Send outgoing test to arduino from pi
    def write(string)
      @outgoing.unshift string
      execute_command_next_tick
    end

    def execute_command_next_tick
      EM.next_tick do
        if status.ready?
          diff = (Time.now - (@time || Time.now)).to_i
          puts "Executing #{@outgoing.count} jobs after #{diff} sconds."
          serial_port.puts @outgoing.pop
          @time = nil
        else
          @time ||= Time.now
          serial_port.puts "F31 P8"
          execute_command_next_tick
        end
      end
    end

    # Handle loss of serial connection
    def disconnect
      log "Connection to device lost"
      @onclose.call if @onclose
    end
  end
end
