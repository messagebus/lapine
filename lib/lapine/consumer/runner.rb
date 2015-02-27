require 'amqp'
require 'digest'
require 'eventmachine'
require 'lapine/annotated_logger'
require 'lapine/consumer/config'
require 'lapine/consumer/connection'
require 'lapine/consumer/environment'
require 'lapine/consumer/message'
require 'lapine/consumer/middleware'
require 'lapine/consumer/topology'
require 'lapine/consumer/dispatcher'

module Lapine
  module Consumer
    class Runner
      attr_reader :argv

      def initialize(argv)
        @argv = argv
        @message_count = 0
        @running_message_count = 0
      end

      def run
        handle_signals!
        Consumer::Environment.new(config).load!
        logger.info 'starting Lapine::Consumer'

        @queue_properties = queue_properties
        EventMachine.run do
          topology.each_binding do |q, conn, routing_key, classes|
            queue = conn.channel.queue(q, @queue_properties).bind(conn.exchange, routing_key: routing_key)
            queue.subscribe(ack: true) do |metadata, payload|

              message = Consumer::Message.new(payload, metadata, logger)
              Middleware.app.call(message) do |message|
                classes.each do |clazz|
                  Lapine::Consumer::Dispatcher.new(clazz, message.payload, message.metadata, logger).dispatch
                end

                if config.debug?
                  @message_count += 1
                  @running_message_count += 1
                end
                metadata.ack
              end

              EventMachine.stop_event_loop if should_exit?
            end
          end

          if config.debug?
            EventMachine.add_periodic_timer(10) do
              logger.info "Lapine::Consumer messages processed=#{@message_count} running_count=#{@running_message_count}"
              @message_count = 0
            end
          end

          EventMachine.add_periodic_timer(5) do
            EventMachine.stop_event_loop if should_exit?
          end
        end

        logger.warn 'exiting Lapine::Consumer'
      end

      def config
        @config ||= Lapine::Consumer::Config.new.load(argv)
      end

      def topology
        @topology ||= ::Lapine::Consumer::Topology.new(config, logger)
      end

      def logger
        @logger ||= config.logfile ? ::Lapine::AnnotatedLogger.new(config.logfile) : ::Lapine::AnnotatedLogger.new(STDOUT)
      end

      def queue_properties
        {}.tap do |props|
          props.merge!(auto_delete: true) if config.transient?
        end
      end

      def should_exit?
        $STOP_LAPINE_CONSUMER
      end

      def handle_signals!
        $STOP_LAPINE_CONSUMER = false
        Signal.trap('INT') { EventMachine.stop }
        Signal.trap('TERM') { $STOP_LAPINE_CONSUMER = true }
      end
    end
  end
end
