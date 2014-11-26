module Lapine
  module Test
    class FakeChannel
      attr_reader :queues

      def initialize
        @queues = {}
      end

      def queue(name = nil, opts = {})
        @queues[name] ||= FakeQueue.new
      end
    end

    class FakeExchange
      attr_reader :histories

      def initialize
        @histories = []
      end

      def channel
        @channel ||= FakeChannel.new
      end

      def bind(history)
        histories << history
      end

      def publish(body, routing_key = nil)
        histories.each do |h|
          h.publish(body, routing_key)
        end
      end
    end

    class FakeQueue
      attr_reader :history

      def bind(exchange)
        @history = MessageHistory.new
        exchange.bind history
        self
      end

      def message_count
        history.message_count
      end
    end

    class MessageHistory
      attr_reader :messages

      def initialize
        @messages = []
      end

      def publish(body, routing_key)
        messages << [body, routing_key]
      end

      def message_count
        messages.size
      end
    end

    class Exchange
      attr_reader :name

      def initialize(name, properties)
        @name = name
      end

      def exchange
        @exchange ||= FakeExchange.new
      end

      def close!
        true
      end
    end
  end
end
