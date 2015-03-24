## SERIAL PORT SIMULATION
## **********************
module FB
  # Used for unit tests
  class StubSerialPort # TODO: Inherit from StringIO?
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
