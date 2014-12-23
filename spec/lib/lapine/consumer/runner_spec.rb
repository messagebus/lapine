require 'spec_helper'
require 'lapine/consumer/runner'
require 'amqp'
require 'em-spec/rspec'

RSpec.describe Lapine::Consumer::Runner do
  include EM::SpecHelper

  class FakerHandler
    def self.handle_lapine_payload(payload, metadata)
    end
  end

  subject(:runner) { Lapine::Consumer::Runner.new(argv) }
  let(:argv) { [] }
  let(:queues) do
    [
      {
        'q' => '',
        'topic' => 'testing.topic',
        'routing_key' => 'testing.update',
        'handlers' =>
          [
            'FakerHandler'
          ]
      }
    ]
  end

  after :each do
    # Comment this out to see the log in the top level folder.
    `rm -f #{logfile}`
  end

  let(:logfile) { File.expand_path('../../../../../lapine.log', __FILE__) }
  let(:config) { double('config',
    logfile: logfile,
    yaml_config: 'fakefil',
    connection_properties: connection_properties,
    require: [],
    queues: queues,
    topics: ['testing.topic'],
    debug?: true,
    transient?: true) }
  let(:connection_properties) { {host: '127.0.0.1', port: 5672, ssl: false, vhost: '/', username: 'guest', password: 'guest'} }
  let(:message) { Oj.dump({'pay' => 'load'}) }

  describe '#run' do
    before do
      allow(runner).to receive(:config).and_return(config)
      allow(runner).to receive(:topology).and_return(::Lapine::Consumer::Topology.new(config, runner.logger))
      allow(runner).to receive(:handle_signals!)
    end

    it 'sends a message to handler' do
      expect(FakerHandler).to receive(:handle_lapine_payload).twice
      em do
        subject.run
        EventMachine.add_timer(0.5) {
          conn = Lapine::Consumer::Connection.new(config, 'testing.topic')
          conn.exchange.publish(message, routing_key: 'testing.update')
          conn.exchange.publish(message, routing_key: 'testing.update')
        }
        EventMachine.add_timer(1.0) { done }
      end
    end
  end

  describe '#config' do
    it 'passes argv to a new config object' do
      allow(Lapine::Consumer::Config).to receive(:new).and_return(config)
      expect(config).to receive(:load).with(argv).and_return(config)
      expect(runner.config).to eq(config)
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

