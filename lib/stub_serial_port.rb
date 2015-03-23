## SERIAL PORT SIMULATION
## **********************

# Used for unit tests

module Fb
  class StubSerialPort
    def initialize(comm_port, parameters)
    end

    def write(text)
      text
    end

    def read(characters)
      characters
    end
  end
end
