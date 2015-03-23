class DefaultSerialPort < SerialPort
  COM_PORT = '/dev/ttyACM0'
  OPTIONS  = { "baud"         => 115200,
              "data_bits"    => 8,
              "stop_bits"    => 1,
              "parity"       => SerialPort::NONE,
              "flow_control" => SerialPort::SOFT }

  def initialize(comm_port = COM_PORT, options = OPTIONS )
    super(comm_port, OPTIONS)
  end
end
