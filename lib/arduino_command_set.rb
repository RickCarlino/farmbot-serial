module FB
  # Composes all logic related to controlling a bot into a single object.
  # Responsible for writing to the serial line.
  class ArduinoCommandSet
    attr_reader :bot

    def initialize(bot)
      @bot = bot
    end

    def emergency_stop
      bot.write("E")
    end

    def move_relative(x, y, z)
      bot.write("G00 X#{x} Y#{y} Z#{z}")
    end
  end
end
