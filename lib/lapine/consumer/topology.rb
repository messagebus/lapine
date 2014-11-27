require 'lapine/consumer/connection'

module Lapine
  module Consumer
    class Topology < Struct.new(:config)

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
            cons[topic] = Lapine::Consumer::Connection.new(config.connection_properties, topic)
          end
        end
        @cons[name]
      end
    end
  end
end
