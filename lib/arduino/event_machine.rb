require 'eventmachine'
module FB
  # Class that is fed into event machine's event loop to handle incoming serial
  # messages asynchronously via EM.attach(). See: EM.attach
  class ArduinoEventMachine < EventMachine::Connection
    class << self
      attr_accessor :arduino
    end

    def self.poll(interval, &blk)
      raise 'You must pass a block' unless block_given?
      EventMachine::PeriodicTimer.new(interval.to_f, &blk)
    end

    def initialize
      @q = self.class.arduino.queue
    end

    # Gets called when data arrives.
    def receive_data(data)
      @q.push(data)
    end

    # Gets called when the connection breaks.
    def unbind
      self.class.arduino.disconnect
      EM.stop
    end

    def self.connect(arduino)
      @arduino = arduino
      EM.attach arduino.serial_port, self
    end
  end
end
