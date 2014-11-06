require 'spec_helper'
require 'lapine/publisher'

RSpec.describe Lapine::Publisher do
  subject(:publisher) { publisher_class.new }

  let(:publisher_class) {
    Class.new.tap do |klass|
      klass.send :include, Lapine::Publisher
      klass.send :exchange, exchange
      klass.send :define_method, :to_hash do
        {}
      end
    end
  }
  let(:exchange) { 'test_exchange' }
  let(:fake_exchange) { double }

  before do
    allow(Lapine).to receive(:find_exchange).with(exchange).and_return(fake_exchange)
  end

  describe '#to_json' do
    before do
      allow(publisher).to receive(:to_hash).and_return({foo: 'bar'})
    end

    it 'turns the output of #to_hash into JSON' do
      expect(publisher.to_json).to eq('{"foo":"bar"}')
    end
  end

  describe '#publish' do
    let(:json) { '{"foo": "bar"}' }

    it 'publishes data with routing key' do
      expect(publisher).to receive(:to_json).and_return(json)
      expect(fake_exchange).to receive(:publish).with(json, routing_key: 'thing.stuff')
      publisher.publish('thing.stuff')
    end
  end
end
