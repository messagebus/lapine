require 'spec_helper'
require 'lapine/consumer/connection'

RSpec.describe Lapine::Consumer::Connection do

  describe "initialize" do
    let(:properties) { {host: '127.0.0.1', port: 5672, ssl: false, vhost: '/', username: 'guest', password: 'guest'} }
    let(:connection) { double('AMQP::Session') }
    let(:channel) { double('AMQP::Channel') }
    let(:config) { double('config', connection_properties: properties) }

    before do
      expect(AMQP).to receive(:connect).with(properties) { connection }
      expect(AMQP::Channel).to receive(:new).with(connection) { channel }
    end

    it "Builds amqp objects" do
      expect(AMQP::Exchange).to receive(:new).with(channel, :topic, 'thing.topic', durable: true)
      described_class.new(config, 'thing.topic')
    end
  end
end

