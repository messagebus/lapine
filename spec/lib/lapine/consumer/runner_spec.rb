require 'spec_helper'
require 'lapine/consumer/runner'
require 'amqp'
require 'em-spec/rspec'

RSpec.describe Lapine::Consumer::Runner do
  include EM::SpecHelper

  class MessagebusTest
    class Faker
      def self.handle_messagebus_payload(payload, metadata)
      end
    end
  end

  subject(:consumer) { Lapine::Consumer::Runner.new(argv) }
  let(:argv) { [] }
  let(:topology) do
    {
      "topics" =>
        [
          "testing.topic"
        ],
      "queues" =>
        [
          {
            "q" => "testing.test",
            "topic" => "testing.topic",
            "routing_key" => "testing.update",
            "handlers" =>
              [
                "MessagebusTest::Faker"
              ]
          }
        ]
    }
  end

  let(:config) { double('config', logfile: '/dev/null', yaml_config: "fakefil", connection_properties: connection_properties) }
  let(:connection_properties) { { host: '127.0.0.1', port: 5672, ssl: false, vhost: '/', username: 'guest', password: 'guest' } }
  let(:message) { {"pay" => "load"}.to_json }

  describe '#run' do
    before do
      allow(consumer).to receive(:config).and_return(config)
      allow(consumer).to receive(:handle_signals!)
    end

    it 'sends a message to handler' do
      expect(MessagebusTest::Faker).to receive(:handle_messagebus_payload).twice
      em do
        subject.run
        # This is not ideal. We should be able to get a callback when rabbit in configured
        # However not sure how to do this. 1 sec is more then ample
        EventMachine.add_timer(1.0) do
          conn = Messagebus::Connection.new(Settings.rabbitmq.connection)
          conn.exchange.publish(message, :routing_key => "testing.update")
          conn.exchange.publish(message, :routing_key => "testing.update")
        end
        EventMachine.add_timer(2.0) { done }
      end
    end
  end

  describe '#config' do
    it 'passes argv to a new config object' do
      allow(Lapine::Consumer::Config).to receive(:new).and_return(config)
      expect(config).to receive(:load).with(argv).and_return(config)
      expect(consumer.config).to eq(config)
    end
  end

  describe '#handle_signals!' do
    it 'traps INT and TERM signals' do
      expect(Signal).to receive(:trap).with('INT')
      expect(Signal).to receive(:trap).with('TERM')
      subject.handle_signals!
    end
  end
end

