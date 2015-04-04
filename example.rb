require_relative 'lib/farmbot-serial'
require 'pry'

bot = FB::Arduino.new # Defaults to '/dev/ttyACM0', can be configured.

puts """
FARMBOT SERIAL SANDBOX. WELCOME!
================================"""
$commands = {
  "q" => "bot.commands.emergency_stop",
  "w" => "bot.commands.move_relative(x: 600)",
  "s" => "bot.commands.move_relative(x: -600)",
  "e" => "bot.commands.home_x",
  "r" => "bot.commands.home_y",
  "t" => "bot.commands.home_z",
  "y" => "bot.commands.home_all",
  "u" => "bot.commands.read_parameter(8)",
  "i" => "bot.commands.write_parameter('x', 0)",
  "o" => "bot.commands.write_pin(pin: 8, value: 1, mode: 1)",
  "p" => "bot.commands.read_status(8)",
}

$commands.each { |k, v| puts "#{k}: #{v}" }

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  attr_reader :bot

  def initialize(bot)
    @bot = bot
  end

  def receive_line(data)
    cmd = $commands[data] || ""
    eval(cmd)
  end
end

puts "Starting now."

EM.run do
  FB::ArduinoEventMachine.connect(bot)
  bot.onmessage { |gcode| print "#{gcode.name}; " }
  bot.onchange { |diff| print "#{diff}; " }
  bot.onclose { puts "bye!"; EM.stop } # Unplug the bot and see
  # EventMachine::PeriodicTimer.new(2) { bot.serial_port.puts "G82" }
  EM.open_keyboard(KeyboardHandler, bot)
end

