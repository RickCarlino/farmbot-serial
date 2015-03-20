describe HardwareInterfaceArduinoWriteStatus do

  before do
    HardwareInterface.current.status = Status.new
    @ramps = HardwareInterfaceArduinoWriteStatus.new()
  end

  it "is busy 1" do
    @ramps.done = 0
    busy = @ramps.is_busy
    expect(busy).to eq(true)
  end

  it "is busy 2" do
    @ramps.done = 1
    busy = @ramps.is_busy
    expect(busy).to eq(false)
  end

  it "split parameter" do
    @ramps.received = "R00 XXX"
    @ramps.split_received()

    expect(@ramps.code).to eq("R00")
    expect(@ramps.params).to eq("XXX")
  end
end
