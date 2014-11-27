require 'amqp'
require 'eventmachine'

module Lapine
  module Consumer
    class Connection
      attr_reader :connection, :channel, :exchange

      def initialize(config, topic = "wnl.topic")
        @connection = AMQP.connect(config.connection_properties)
        @channel = AMQP::Channel.new(connection)
        @exchange = AMQP::Exchange.new(channel, :topic, topic, durable: true)
      end
    end
  end
end
