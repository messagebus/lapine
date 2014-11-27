require 'spec_helper'
require 'lapine/consumer/topology'

RSpec.describe Lapine::Consumer::Topology do
  module MessageBusTest
    class Clazz
    end
  end

  let(:topics) {
    [
      "a.topic",
      "b.topic"
    ]
  }
  let(:queues) {
    [{
      "q" => "store.buyable",
      "topic" => "a.topic",
      "routing_key" =>
      "store.buyable.update",
        "handlers" => ["MessageBusTest::Clazz"]
    }]
  }
  let(:connection_properties) {
    {}
  }
  let(:config) do
    double('config', topics: topics, queues: queues, connection_properties: connection_properties)
  end

  let(:topology) { Lapine::Consumer::Topology.new(config) }

  describe "#each_topic" do
    it "yields correct dount" do
      expect { |b| topology.each_topic(&b) }.to yield_control.twice
    end

    it "yields all topics in order" do
      expect { |b| topology.each_topic(&b) }.to yield_successive_args("a.topic", "b.topic")
    end
  end

  describe "#each_binding" do
    let(:conn) { double('connection') }
    before do
      allow(Lapine::Consumer::Connection).to receive(:new) { conn }
    end

    it "yields correct count" do
      expect { |b| topology.each_binding(&b) }.to yield_control.once
    end

    it "yields expected arguments" do
      expect do |b|
        topology.each_binding(&b)
      end.to yield_with_args("store.buyable",
        conn,
        "store.buyable.update",
        [MessageBusTest::Clazz])
    end
  end
end

