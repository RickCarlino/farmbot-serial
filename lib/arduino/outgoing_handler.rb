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
      bot.write("E")
    end

    def move_relative(x: 0, y: 0, z: 0, s: 100)
      bot.write(FB::Gcode.new("G00 X#{x} Y#{y} Z#{z}"))
    end

  end
end

