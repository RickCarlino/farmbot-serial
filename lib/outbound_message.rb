# An outbound (Pi -> Arduino) status message.
# Originally HardwareInterfaceArduinoWriteStatus
class OutboundMessage

  attr_accessor :done, :code, :received, :start, :log, :onscreen, :text,
                :params, :timeout

  def initialize(text)
    @text     = text
    @done     = 0
    @code     = ''
    @received = ''
    @text     = ''
    @params   = ''
    @log      = false
    @onscreen = false
    @start    = Time.now
    @timeout  = 5
  end

  def parse_response!
    # get the parameter and data part
    @code   = received[0..2].upcase
    @params = received[3..-1].to_s.upcase.strip
  end

  # handle the incoming message depending on the first code number
  #
  def process_code_and_params

  # process the feedback
  case self.code

  # command received by arduino
  when 'R01'
    self.timeout = 90
  # command is finished
  when 'R02'
    self.done = 1
    @is_done = true
  # command is finished with errors
  when 'R03'
    self.done = 1
    @is_done = true
  # command is still ongoing
  when 'R04'
    self.start = Time.now
    self.timeout = 90
  # specific feedback that is processes separately
  else
    process_value(self.code,self.params)
  end

  self.received = ''

  end

end
