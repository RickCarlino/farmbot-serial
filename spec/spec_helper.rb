require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end
require 'pry'
require 'farmbot-serial'
require_relative 'fixtures/stub_serial_port'
RSpec.configure do |config|
end

def within_event_loop
  EM.run do
    yield
    EM.next_tick { EM.stop }
  end
end
