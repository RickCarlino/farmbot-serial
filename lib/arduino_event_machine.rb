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
      @polling_interval = interval.to_f
      @polling_callback = blk
    end

    # TODO: Not sure if its a good idea to be calling EM in here if we ever want
    # to add other EM based services. Will leave for now.
    def self.start(arduino)
      @arduino = arduino
      EM.run do
        EM.attach arduino.serial_port, self
        if @polling_callback
          EventMachine::PeriodicTimer.new(@polling_interval) do
            @polling_callback.call(@arduino)
          end
        end
      end
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
