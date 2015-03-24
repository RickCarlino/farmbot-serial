require 'eventmachine'
module FB
  # Class that is fed into event machine's event loop to handle incoming serial
  # messages asynchronously via EM.attach(). See: EM.attach
  class ArduinoEventMachine < EventMachine::Connection
    class << self
      attr_accessor :arduino
    end

    def receive_data(data)
      self.class.arduino.read(data)
    end

    # Gets called when the connection breaks.
    def unbind
      self.class.arduino.disconnect
      EM.stop
    end
  end
end
