require 'spec_helper'
require 'lapine/test/rspec_helper'

RSpec.describe Lapine::Test::Exchange, with_rspec_helper: true do
  class Publisher
    include Lapine::Publisher

    exchange 'my.topic'

    def to_hash
      {
        omg: 'lol'
      }
    end
  end

  let(:exchange) { Lapine.find_exchange('my.topic') }
  let(:queue) { exchange.channel.queue.bind(exchange) }

  before do
    Lapine.add_connection 'conn', {} 
    Lapine.add_exchange 'my.topic', connection: 'conn'
    queue
  end

  describe 'publish' do
    it 'changes the queue message count' do
      expect {
        Publisher.new.publish
      }.to change {
        queue.message_count
      }.to(1)
    end

    it 'saves message for later introspection' do
      Publisher.new.publish('my.things')
      message = ['{"omg":"lol"}', {routing_key: 'my.things'}]
      expect(queue.messages).to include(message)
    end
  end  
end
