require 'amqp'
require 'eventmachine'

module Lapine
  module Consumer
    class Connection
      attr_reader :connection, :channel, :exchange

      def initialize(config, topic)
        @connection = AMQP.connect(config.connection_properties)
        @channel = AMQP::Channel.new(connection)
        @exchange = AMQP::Exchange.new(channel, :topic, topic, durable: true)
      end

      def close!
        @connection.close if @connection.connected?
      end
    end
  end
end
