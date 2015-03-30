require_relative 'lib/farmbot-serial'
require 'pry'

bot = FB::Arduino.new # Defaults to '/dev/ttyACM0', can be configured.

EM.run do
  FB::ArduinoEventMachine.connect(bot)

  # Example 1: Writing to the serial line the "correct way" every 1.5 seconds.
  command = FB::Gcode.new('G01 X250 Y250 Z250')
  EventMachine::PeriodicTimer.new(1.5) { bot.commands.move_relative(command) }

  # Example 2: Writing raw strings to serial every 2.5
  EventMachine::PeriodicTimer.new(2.5) { bot.write("F31 P8") }

  # This will execute after status has been updated / internal code.
  bot.onmessage { |gcode| puts "SERIAL  IN: #{gcode.name}" }

  # Try pulling the USB cable out to test this one.
  bot.onclose { EM.stop }
end

