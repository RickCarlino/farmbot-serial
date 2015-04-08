require 'spec_helper'

describe FB::IncomingHandler do

  let(:status) { FB::Status.new }

  it "capitalizes all incoming status keys" do
    status[:bUsY] = 345345345
    expect(status[:BUSY]).to eq(345345345)
    expect(status[:bUsy]).to eq(345345345)
    expect(status[:busy]).to eq(345345345)
  end

  it "symbolizes all incoming status keys" do
    status['busy'] = 878787
    expect(status[:bUsy]).to eq(878787)
  end

  it "indicates BUSY status via #ready?()" do
    status['busy'] = 1
    expect(status.ready?).to be_falsey
    status['busy'] = 0
    expect(status.ready?).to be_truthy
  end

  it 'broadcasts status changes' do
    @diff = {}

    within_event_loop do
      status.onchange { |diff| @diff = diff }
      status[:busy] = 1
      status[:busy] = 0
      status[:busy] = 1
    end

    expect(status[:busy]).to eq(1)
    expect(@diff).to eq(:BUSY => 1)
  end
end

