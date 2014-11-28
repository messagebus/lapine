require 'lapine/consumer/connection'

module Lapine
  module Consumer
    class Topology < Struct.new(:config, :logger)

      def each_binding
        config.queues.each do |node|
          classes = node['handlers'].map do |handler|
            handler.split('::').inject(Object) do |const, name|
              const.const_get(name)
            end
          end

          yield node['q'], get_conn(node['topic']), node['routing_key'], classes
        end
      end


      def each_topic
        config.topics.each do |topic|
          yield topic
        end
      end

      private

      def get_conn(name)
        @cons ||= {}.tap do |cons|
          each_topic do |topic|
            debug "Connecting to RabbiMQ: topic: #{topic}, #{config.connection_properties}"
            cons[topic] = Lapine::Consumer::Connection.new(config, topic)
          end
        end
        @cons[name]
      end

      def debug(msg)
        return unless config.debug?
        return unless logger
        logger.info msg
      end
    end
  end
end
