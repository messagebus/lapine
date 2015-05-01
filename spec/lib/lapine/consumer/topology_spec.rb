require 'spec_helper'
require 'lapine/consumer/topology'

RSpec.describe Lapine::Consumer::Topology do
  module MessageBusTest
    class Clazz
    end
  end

  let(:topics) {
    [
      'a.topic',
      'b.topic'
    ]
  }
  let(:queues) {
    [{
      'q' => 'store.buyable',
      'topic' => 'a.topic',
      'routing_key' => 'store.buyable.update',
      'handlers' => ['MessageBusTest::Clazz']
    }]
  }
  let(:connection_properties) {
    {}
  }
  let(:queues_to_delete) { [] }
  let(:config) do
    double('config',
           topics: topics,
           queues: queues,
           delete_queues: queues_to_delete,
           connection_properties: connection_properties,
           debug?: debug)
  end

  subject(:topology) { Lapine::Consumer::Topology.new(config, logger) }
  let(:debug) { false }
  let(:logger) { nil }

  describe '#each_topic' do
    it 'yields correct dount' do
      expect { |b| topology.each_topic(&b) }.to yield_control.twice
    end

    it 'yields all topics in order' do
      expect { |b| topology.each_topic(&b) }.to yield_successive_args('a.topic', 'b.topic')
    end
  end

  describe '#each_queue_to_delete' do
    let(:conn) { double('connection') }
    let(:queues_to_delete) { [
      {'q' => 'queue.name', 'topic' => 'a.topic', 'handlers' => ['MessageBusTest::Clazz']},
      {'q' => 'other.queue.name', 'topic' => 'a.topic', 'handlers' => ['MessageBusTest::Clazz']}
    ] }
    before do
      allow(Lapine::Consumer::Connection).to receive(:new) { conn }
    end

    it 'yields queue name with connection' do
      expect { |b|
        topology.each_queue_to_delete(&b)
      }.to yield_successive_args(
        ['queue.name', conn, nil, [MessageBusTest::Clazz]],
        ['other.queue.name', conn, nil, [MessageBusTest::Clazz]]
      )
    end
  end

  describe '#each_binding' do
    let(:conn) { double('connection') }

    before do
      allow(Lapine::Consumer::Connection).to receive(:new) { conn }
    end

    it 'yields correct count' do
      expect { |b| topology.each_binding(&b) }.to yield_control.once
    end

    it 'yields expected arguments' do
      expect { |b|
        topology.each_binding(&b)
      }.to yield_with_args('store.buyable',
        conn,
        'store.buyable.update',
        [MessageBusTest::Clazz])
    end

    context 'with a logger and debug mode' do
      let(:debug) { true }
      let(:logger) { double('logger', info: true) }

      it 'logs each connection' do
        topology.each_binding {}
        expect(logger).to have_received(:info).with("Connecting to RabbiMQ: topic: a.topic, #{config.connection_properties}")
        expect(logger).to have_received(:info).with("Connecting to RabbiMQ: topic: b.topic, #{config.connection_properties}")
      end
    end
  end
end

