module FB
  # Handles Gcode that moves from the Arduino to the Pi (Arduino -> Pi).
  class IncomingHandler
    attr_reader :bot

    def initialize(bot)
      @bot = bot
    end

    def execute(gcode)
      self.send(gcode.name, gcode)
    rescue NoMethodError
      bot.log "#{gcode.name} is a valid GCode, but no input handler method exists"
    end

    def unknown(gcode)
      bot.log "Don't know how to parse incoming GCode: #{gcode}"
    end

    def report_parameter_value(gcode)
      bot.status.set_pin(gcode.value_of(:P), gcode.value_of(:V))
    end

    def reporting_end_stops(gcode)
      bot.status.gcode_update(gcode)
    end

    def report_current_position(gcode)
      bot.status.gcode_update(gcode)
    end

    def report_status_value(gcode)
      # TODO: Verfiy the accuracy of this code. CC: @timevww
      bot.status.set_pin(gcode.value_of(:P), gcode.value_of(:V))
    end

    def received(gcode)
      bot.status[:busy] = 1
    end

    def idle(gcode)
      bot.status[:busy] = 0
    end

    def done(gcode)
      bot.status[:busy] = 0
    end

    def busy(gcode)
      bot.status[:busy] = 1
    end

    def report_software_version(gcode)
      nil # Don't need the info right now.
    end

    def debug_message(*)
      nil # Squelch debug messages.
    end
  end
end
