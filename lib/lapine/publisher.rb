require 'oj'

module Lapine
  module Publisher

    def self.included(klass)
      klass.send :extend, ClassMethods
    end

    def publish(routing_key = nil)
      Lapine.find_exchange(self.class.current_lapine_exchange).publish(to_json, routing_key: routing_key)
    end

    def to_json
      ::Oj.dump(to_hash, mode: :compat)
    end

    module ClassMethods
      def exchange(name)
        @lapine_exchange = name
      end

      def current_lapine_exchange
        @lapine_exchange
      end
    end
  end
end
