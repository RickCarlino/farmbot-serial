require_relative 'lib/farmbot-serial'
require 'pry'

bot = FB::Arduino.new # Defaults to '/dev/ttyACM0', can be configured.

EM.run do
  FB::ArduinoEventMachine.connect(bot)

  # Example 1: Writing to the serial line the "correct way" every 1.5 seconds.
  EventMachine::PeriodicTimer.new(2) { bot.commands.move_relative(x: 300) }

  EventMachine::PeriodicTimer.new(2) { bot.write(FB::Gcode.new("F31 P8")) }

  bot.onmessage { |gcode| bot.log "Got #{gcode}" }
  bot.onchange { |diff| bot.log "Status Changed: #{diff}" }
  bot.onclose { puts "bye!"; EM.stop } # Unplug the bot and see!
end

