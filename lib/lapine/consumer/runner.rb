require 'amqp'
require 'digest'
require 'eventmachine'
require 'logger'
require 'lapine/consumer/config'
require 'lapine/consumer/connection'
require 'lapine/consumer/topology'
require 'lapine/consumer/dispatcher'

module Lapine
  module Consumer
    class Runner
      attr_reader :argv, :message_count

      def initialize(argv)
        @argv = argv
        @message_count = 0
      end

      def run
        handle_signals!
        logger.info 'starting Messagebus::Consumer'

        EventMachine.run do
          conn = Lapine::Consumer::Connection.new(config)

          topology.each_binding do |q, conn, routing_key, classes|
            queue = conn.channel.queue(q).bind(conn.exchange, routing_key: routing_key)
            queue.subscribe(ack: true) do |metadata, payload|
              classes.each do |clazz|
                Lapine::Consumer::Dispatcher.new(clazz, payload, metadata, logger).dispatch
              end

              message_count += 1

              metadata.ack
            end
          end

          EventMachine.add_periodic_timer(10) do
            logger.info "Messagebus::Consumer messages processed=#{message_count}"
          end
        end

        logger.warn 'exiting Messagebus::Consumer'
      end

      def config
        @config ||= Lapine::Consumer::Config.new.load(argv)
      end

      def topology
        @topology ||= ::Lapine::Consumer::Topology.new(config)
      end

      def logger
        @logger ||= config.logfile ? Logger.new(config.logfile) : Logger.new(STDOUT)
      end

      def handle_signals!
        Signal.trap('INT') { EventMachine.stop }
        Signal.trap('TERM') { EventMachine.stop }
      end
    end
  end
end
