# Farmbot-Serial

A ruby gem for controlling Farmbot via serial line with EventMachine.

## Usage

```
gem install farmbot-serial, '0.0.5'
```

```ruby
require 'farmbot-serial'

bot = FB::Arduino.new # Defaults to '/dev/ttyACM0'

EM.run do
  # Register bot with event loop.
  FB::ArduinoEventMachine.connect(bot)
  # Make the bot flinch every 5 seconds...
  FB::ArduinoEventMachine.poll(5) { bot.commands.move_relative(1, 1, 1) }
  # Immediate handling of incoming messages.
  bot.onmessage { |data| puts "Serial message in: #{data}" }
  # Stop event loop if connection closes or serial cable is disconnected
  bot.onclose   { EM.stop }
end
```
