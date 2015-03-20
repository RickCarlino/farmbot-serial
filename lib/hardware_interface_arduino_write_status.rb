module Fb
  class HardwareInterfaceArduinoWriteStatus

    attr_accessor :done, :code, :received, :start, :log, :onscreen, :text,
      :params, :timeout

    def initialize
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

    def is_busy
      Time.now - @start < @timeout and @done == 0
    end

    def split_received
      # get the parameter and data part
      @code   = received[0..2].upcase
      @params = received[3..-1].to_s.upcase.strip
    end

  end
end
