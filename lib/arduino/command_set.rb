module FB
  # Composes all logic related to controlling a bot into a single object.
  # Responsible for writing to the serial line.
  class ArduinoCommandSet
    attr_reader :bot

    class UnhandledGcode < StandardError; end

    def initialize(bot)
      @bot = bot
    end

    def execute(gcode)
      self.send(gcode.name, gcode)
    end

    def emergency_stop(*)
      bot.write("E")
    end

    def move_relative(gcode)
      bot.write(gcode.to_s)
    end

    def unknown(gcode)
      raise UnhandledGcode, "Dont know how to parse '#{gcode.to_s}'"
    end

    def received(gcode)
      bot.status[:busy] = 1
    end

    def reporting_end_stops(gcode)
      bot.status.gcode_update(gcode)
    end

    def report_current_position(gcode)
      bot.status.gcode_update(gcode)
    end

    def done(gcode)
      bot.status[:busy] = 0
    end

    def report_status_value(gcode)
      bot.status.gcode_update(gcode)
    end
  end
end

