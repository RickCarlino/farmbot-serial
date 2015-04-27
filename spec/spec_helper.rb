require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end
require 'pry'
require 'farmbot-serial'

require_relative 'fakes/fake_serial_port'
require_relative 'fakes/fake_logger'
require_relative 'fakes/fake_arduino'

RSpec.configure do |config|
end

# This is used for testing things that require an event loop. Once run, you can
# observe / make assertions on side effects.
def within_event_loop(ticks_remaining = 1)
  EM.run do
    EventMachine::PeriodicTimer.new(0.1) { EM.stop }
    yield
  end
end
