module FB
  # Rename to StatusIndicator or StatusRegister
  class HardwareInterfaceArduinoValuesReceived

    attr_accessor :code, :text, :external_info

    # value holders with the name used in the serial
    # communucation as they are received from arduino
    attr_accessor :p , :v, :x , :y , :z, :xa, :xb, :ya, :yb, :za, :zb


    def initialize
      @p  = -1
      @v  = 0
      @x  = 0
      @y  = 0
      @z  = 0
      @xa = 0
      @xb = 0
      @ya = 0
      @yb = 0
      @za = 0
      @zb = 0
      @text = ''
      @code = 0
    end
    # Change name to []=?
    def load_parameter(name, value)
      name = name.upcase.to_sym
      case name
        when :P
          @p  = value
        when :V
          @v  = value
        when :XA
          @xa = value
        when :XB
          @xb = value
        when :YA
          @ya = value
        when :YB
          @yb = value
        when :ZA
          @za = value
        when :ZB
          @zb = value
        when :X
          @x  = value
        when :Y
          @y  = value
        when :Z
          @z  = value
        else
          raise "Unknown status symbol '#{name}'"
      end
    end

  end
end
