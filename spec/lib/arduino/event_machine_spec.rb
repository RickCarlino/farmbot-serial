require 'spec_helper'

describe FB::ArduinoEventMachine do
  let(:logger) { FakeLogger.new }
  let(:serial_port) { FakeSerialPort.new }
  let(:bot) { FB::Arduino.new(serial_port: serial_port, logger: logger) }

  it "initializes" do
    expect(bot.outbound_queue).to eq([])
    expect(bot.serial_port).to be(serial_port)
    expect(bot.logger).to be(logger)
    expect(bot.inbound_queue).to be_kind_of(EM::Channel)
    expect(bot.commands).to be_kind_of(FB::OutgoingHandler)
    expect(bot.inputs).to be_kind_of(FB::IncomingHandler)
    expect(bot.status).to be_kind_of(FB::Status)
  end

  it "logs" do
    bot.log 'Hello, world!'
    expect(logger.message).to eq('Hello, world!')
  end
end

