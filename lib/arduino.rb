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
    Position = Struct.new(:x, :y, :z)

    attr_accessor :serial_port, :logger, :commands, :inbound_queue, :status,
      :inputs, :outbound_queue

    # Initialize and provide a serial object, as well as an IO object to send
    # log messages to. Default SerialPort is DefaultSerialPort. Default logger
    # is STDOUT
    def initialize(serial_port: DefaultSerialPort.new, logger: STDOUT)
      @outbound_queue = [] # Pi -> Arduino Gcode
      @inbound_queue  = EM::Channel.new # Pi <- Arduino

      @serial_port = serial_port
      @logger      = logger
      @commands    = FB::OutgoingHandler.new(self)
      @inputs      = FB::IncomingHandler.new(self)
      @status      = FB::Status.new

      start_event_listeners
    end

    # Log to screen/file/IO stream
    def log(message)
      logger.puts(message)
    end

    # Send outgoing test to arduino from pi
    def write(gcode)
      @outbound_queue.unshift gcode
      execute_command_next_tick
    end

    def onchange(&blk)
      @onchange = blk
    end

    # Handle incoming text from arduino into pi
    def onmessage(&blk)
      @onmessage = blk
    end

    def onclose(&blk)
      @onclose = blk
    end

    # Handle loss of serial connection
    def disconnect
      log "Connection to device lost"
      @onclose.call if @onclose
    end

    def current_position
      Position.new(status[:X], status[:Y], status[:Z])
    end

    private

    # Highest priority message when processing incoming Gcode. Use for system
    # level status changes.
    def parse_incoming(gcode)
      inputs.execute(gcode)
    end

    def execute_command_next_tick
      EM.next_tick do
        status.ready? ? pop_gcode_off_queue : execute_command_next_tick
      end
    end

    def pop_gcode_off_queue
      # move_relative x: 600; move_relative x: 600; move_relative x: 600;
      gcode = @outbound_queue.pop

      unless gcode.name == :read_parameter
        seconds = (DateTime.now - (@last || DateTime.now)) * 86400
        @last = DateTime.now
        puts "Sending #{gcode.name} after #{seconds.to_f}"
      end
      serial_port.puts gcode
      status[:last] = gcode.name if gcode.respond_to?(:name)
      status[:BUSY] = 1
    end

    def start_event_listeners
      status.onchange { |diff| @onchange.call(diff) if @onchange }
      inbound_queue.subscribe do |gcodes|
        gcodes.each do |gcode|
          parse_incoming(gcode)
          @onmessage.call(gcode) if @onmessage
        end
      end
    end
  end
end
