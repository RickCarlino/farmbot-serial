require 'spec_helper'

describe FB::OutgoingHandler do

  let(:handler) { FB::OutgoingHandler.new(FakeArduino.new) }
  let(:bot) { handler.bot }
  it 'initializes' do
    handler
    expect(handler.bot).to be_kind_of(FB::Arduino)
  end

  it 'emergency_stop()s' do
    10.times { handler.move_relative(x: 1) }

    handler.emergency_stop

    expect(bot.outbound_queue.length).to eq(0)
    expect(bot.status[:LAST]).to eq(:emergency_stop)
    expect(bot.serial_port.message).to eq('E')
  end

  it 'adjusts relative movements to bots position RIGHT NOW' do
    handler.move_relative(x: 1, y: 2, z: 3)
    expect(bot.next_cmd.to_s).to eq("G0 X1 Y2 Z3")
    [:x, :y, :z].each { |pos| bot.status[pos] = 3 }
    expect(bot.next_cmd.to_s).to eq("G0 X4 Y5 Z6")
  end

  it 'never goes behind the 0 line' do
    handler.move_relative(x: -999, y: -999, z: -999)
    expect(bot.outbound_queue.first.value_of(:x)).to eq(0)
    expect(bot.outbound_queue.first.value_of(:y)).to eq(0)
    expect(bot.outbound_queue.first.value_of(:z)).to eq(0)
  end

  it 'Moves absolute' do
    [:x, :y, :z].each { |pos| bot.status[pos] = 300 }
    handler.move_absolute(x: 5, y: 6, z: 7)
    expect(bot.next_cmd.to_s).to eq("G0 X5 Y6 Z7")
    handler.move_absolute(x: 7, y: 8, z: 9)
    expect(bot.next_cmd.to_s).to eq("G0 X7 Y8 Z9")
  end

  it 'Never goes farther than 0 when moving absolute' do
    handler.move_absolute(x: -987, y: -654, z: -321)
    expect(bot.next_cmd.to_s).to eq("G0 X0 Y0 Z0")
  end

  it 'homes x, y, z, all' do
    handler.home_x
    expect(bot.next_cmd.to_s).to eq("F11")
    handler.home_y
    expect(bot.next_cmd.to_s).to eq("F12")
    handler.home_z
    expect(bot.next_cmd.to_s).to eq("F13")
    handler.home_all
    expect(bot.next_cmd.to_s).to eq("G28")
  end

  it 'reads / writes parameters' do
    handler.read_parameter(0)
    expect(bot.next_cmd.to_s).to eq("F21 P0")
    handler.write_parameter(0, 1)
    expect(bot.next_cmd.to_s).to eq("F22 P0 V1")
  end

  it 'reads status' do
    handler.read_status(0)
    expect(bot.next_cmd.to_s).to eq("F31 P0")
  end

  it 'writes to a pin' do
    handler.pin_write(pin: 0, value: 1, mode: 3)
    expect(bot.next_cmd.to_s).to eq("F41 P0 V1 M3")
  end
end
