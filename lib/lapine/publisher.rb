require 'oj'

module Lapine
  module Publisher

    def self.included(klass)
      klass.send :extend, ClassMethods
    end

    def publish(routing_key = nil)
      Lapine.find_exchange(self.class.instance_variable_get(:@exchange)).publish(to_json, routing_key: routing_key)
    end

    def to_json
      ::Oj.dump(to_hash, mode: :compat)
    end

    module ClassMethods
      def exchange(name)
        @exchange = name
      end
    end
  end
end
