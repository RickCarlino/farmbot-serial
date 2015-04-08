require_relative 'lib/default_serial_port'
require 'pry'

serial = FB::DefaultSerialPort.new
binding.pry

puts 'Bye!'
