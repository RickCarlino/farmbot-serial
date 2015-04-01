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
      bot.serial_port.puts "E" # Don't queue this one- write to serial line.
    end

    def move_relative(x: 0, y: 0, z: 0, s: 100)
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

  private

    def write(str)
      bot.write(FB::Gcode.new(str))
    end
  end
end

