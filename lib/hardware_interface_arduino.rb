## HARDWARE INTERFACE
## ******************

# Communicate with the arduino using a serial interface
# All information is exchanged using a variation of g-code
# Parameters are stored in the database
module Fb
  class HardwareInterfaceArduino

    attr_accessor :serial_port
 
    attr_reader :is_busy
    attr_reader :is_error
    attr_reader :is_done
    attr_reader :parameters

    # initialize the interface
    #
    def initialize(test_mode)
      @status_debug_msg  = $debug_msg
      @test_mode         = test_mode      

      # connect to arduino
      connect_board()

      @external_info     = ""
      @parameters        = []

      @is_busy           = false
      @is_error          = false
      @is_done           = false

    end

    ## ARDUINO HANLDING
    ## ****************

    # connect to the serial port and start communicating with the arduino/firmata protocol
    #
    def connect_board

      parameters =
      {
        "baud"         => 115200,
        "data_bits"    => 8,
        "stop_bits"    => 1,
        "parity"       => SerialPort::NONE,
        "flow_control" => SerialPort::SOFT
      }

      comm_port = '/dev/ttyACM0'
      @serial_port = SerialPort.new(comm_port, parameters) if @test_mode == false
      @serial_port = SerialPortSim.new(comm_port, parameters) if @test_mode == true

    end

    # write a command to the robot
    #
    def write_command(text, log, onscreen)
      begin

        write_status = create_write_status(text, log, onscreen)
        write_to_serial(write_status)
        
        @parameters = []
        @is_busy    = true
        @is_error   = false

      rescue => e
        handle_execution_exception(e)
      end
    end

    # check the responses from the robot
    #
    def check_command_execution
      begin
        if Time.now - write_status.start < write_status.timeout and @is_done == 0
          @is_error = true
        else
          check_emergency_stop
          process_feedback(write_status)
        end
      rescue => e
        handle_execution_exception(e)
      end
    end


    def create_write_status(text, log, onscreen)
      write_status = Fb::HardwareInterfaceArduinoWriteStatus.new
      write_status.text     = text
      write_status.log      = log

      write_status.onscreen = onscreen
      write_status
    end

    def handle_execution_exception(e)
      puts("ST: serial error\n#{e.message}\n#{e.backtrace.inspect}")
      @serial_port.rts = 1
      connect_board
      @is_error = true
    end

    # set the serial port ready to send and write the text
    #
    def write_to_serial(write_status)
      puts "WR: #{write_status.text}" if write_status.onscreen
      @serial_port.read_timeout = 2
      clean_serial_buffer() if @test_mode == false
      serial_port_write( "#{write_status.text}\n" )
    end

    # receive all characters coming from the serial port
    #
    def process_feedback(write_status)
      i = @serial_port.read(1)

      if i != nil
        i.each_char do |c|
          process_characters(write_status, c)
        end
      else
        sleep 0.001 if @test_mode == false
      end
    end

    # keep incoming characters in a buffer until it is a complete string
    #
    def process_characters(write_status, c)

      if c == "\r" or c == "\n"
        if write_status.received.length >= 3
          log_incoming_text(write_status)
          write_status.split_received
          process_code_and_params(write_status)
        end
      else
        write_status.received = write_status.received + c
      end
    end

    # handle the incoming message depending on the first code number
    #
    def process_code_and_params(write_status)

      # process the feedback
      case write_status.code

        # command received by arduino
        when 'R01'
          write_status.timeout = 90

        # command is finished
        when 'R02'
          write_status.done = 1
          @is_done = true
        # command is finished with errors
        when 'R03'
          write_status.done = 1
          @is_done = true
        # command is still ongoing
        when 'R04'
          write_status.start = Time.now
          write_status.timeout = 90

        # specific feedback that is processes separately
        else
          process_value(write_status.code,write_status.params)
      end

      write_status.received = ''

    end

    # empty the input buffer so no old data is processed
    #
    def clean_serial_buffer
      while (@serial_port.read(1) != nil)
      end
    end

    # write something to the serial port
    def serial_port_write(text)
      @serial_port.write( text )
    end

    # if there is an emergency stop, immediately write it to the arduino
    #
    def check_emergency_stop
      if (Fb::HardwareInterface.current.status.emergency_stop)
       serial_port_write( "E\n" )
      end
    end

    # write to log
    #
    def log_incoming_text(write_status)
      puts "RD: #{write_status.received}" if write_status.onscreen
    end

    def process_value_split(code, params, text)

      params = Fb::HardwareInterfaceArduinoValuesReceived.new

      # get all separate parameters from the text
      text.split(' ').each do |param|

        if code == "R81"
         # this is the only code that uses two letter parameters
          par_code  = param[0..1].to_s
          par_value = param[2..-1].to_i
        else
          par_code  = param[0..0].to_s
          par_value = param[1..-1].to_i
        end

        params.load_parameter(par_code, par_value)

      end

      return params
    end

    # process values received from arduino
    #
    def process_value(code,text)

      # get all parameters in the current text
      params = process_value_split(code, text)

      # save the list for the client
      @parameters << params

    end

    def puts(*)
      # Too many messages in the test buffer right now. Will delete this later.
      # just disabling it for now.
      STDOUT.print('x')
    end
  end
end
