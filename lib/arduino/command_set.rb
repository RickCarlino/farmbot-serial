module FB
  # Composes all logic related to controlling a bot into a single object.
  # Responsible for writing to the serial line.
  class ArduinoCommandSet
    attr_reader :bot

    def initialize(bot)
      @bot = bot
    end

    def execute(gcode)
      puts "SERIAL OUT: #{gcode.name}"
      self.send(gcode.name, gcode)
    end

    def emergency_stop(*)
      bot.write("E")
    end

    def move_relative(gcode)
      bot.write(gcode.to_s)
    end

    def received(gcode)
    end

    def reporting_end_stops(gcode)
    end

    def report_current_position(gcode)
    end

    def done(gcode)
    end

    def report_status_value(gcode)
    end
  end
end

