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
      @q, @buffer = self.class.arduino.queue, ''
    end

    # Gets called when data arrives.
    def receive_data(data)
      split_into_chunks(data).each do |chunk|
        if chunk.end_with?("\r\n")
          add_to_buffer(chunk)
          send_buffer
          clear_buffer
        else
          add_to_buffer(chunk)
        end
      end
    end

    def clear_buffer
      @buffer = ''
    end

    def add_to_buffer(d)
      @buffer += d
    end

    def send_buffer
      @q << Gcode.parse_lines(@buffer)
    end

    def split_into_chunks(data)
      data.gsub("\r\n", '!@').split('@').map{ |d| d.gsub('!', "\r\n") }
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
