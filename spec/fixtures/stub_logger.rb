class StubLogger < StringIO
  def initialize("")
    super
  end
end
