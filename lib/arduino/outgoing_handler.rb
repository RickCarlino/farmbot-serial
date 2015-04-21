module FB
  # Responsible for writing to the serial line. Sends Gcode from the pi to the
  # arduino. (Pi -> Arduino)
  class OutgoingHandler
    attr_reader :bot

    class UnhandledGcode < StandardError; end

    def initialize(bot)
      @bot = bot
    end

    def emergency_stop(*)
      # This message is special- it is the only method that bypasses the queue.
      bot.outbound_queue = []  # Dump pending commands.
      bot.serial_port.puts "E" # Don't queue this one- write to serial line.
      bot.status[:last] = :emergency_stop
    end

    def move_relative(x: 0, y: 0, z: 0, s: 100)
      x = [(bot.current_position.x +  (x || 0)), 0].max
      y = [(bot.current_position.y +  (y || 0)), 0].max
      z = [(bot.current_position.z +  (z || 0)), 0].max
      print '%'
      write { FB::Gcode.new { "G00 X#{x} Y#{y} Z#{z}" } }
    end

    def move_absolute(x: 0, y: 0, z: 0, s: 100)
      write "G00 X#{x} Y#{y} Z#{z}"
    end

    def home_x
      write "F11"
    end

    def home_y
      write "F12"
    end

    def home_z
      write "F13"
    end

    def home_all
      write "G28"
    end

    def read_parameter(num)
      write "F21 P#{num}"
    end

    def write_parameter(num, val)
      write "F22 P#{num} V#{val}"
    end

    def read_status(pin)
      write "F31 P#{pin}"
    end

    def pin_write(pin:, value:, mode:)
      write "F41 P#{pin} V#{value} M#{mode}"
      bot.status.set_pin(pin, value)
    end

  private

    def write(str = "\n")
      bot.write( block_given? ? yield : FB::Gcode.new{ str } )
    end
  end
end

