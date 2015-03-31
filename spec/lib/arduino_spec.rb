require 'spec_helper'

describe FB::Arduino do
  let(:logger) { StringIO.new("") }
  let(:bot) do
    FB::Arduino.new(StubSerialPort.new(0, 0), logger)
  end

  it "initializes" do
    expect(bot).to be_kind_of(FB::Arduino)
    expect(bot.serial_port).to be_kind_of(StubSerialPort)
    expect(bot.logger).to be_kind_of(StringIO)
    expect(bot.commands).to be_kind_of(FB::OutgoingHandler)
    expect(bot.queue).to be_kind_of(EM::Channel)
    expect(bot.status).to be_kind_of(FB::Status)
    expect(bot.inputs).to be_kind_of(FB::IncomingHandler)
  end

  it 'prints to the logger object' do
    bot.log "Hello, World!"
    bot.logger.rewind
    expect(bot.logger.gets.chomp).to eq("Hello, World!")
  end

end

