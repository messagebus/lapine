require 'lapine/test/exchange'

module Lapine
  module Test
    module RSpecHelper
      def self.setup(example)
        example.allow(Lapine::Exchange).to(
          example.receive(:new) { |name, properties|
            Lapine::Test::Exchange.new(name, properties)
          }
        )
      end

      def self.teardown
        Lapine.close_connections!
      end
    end
  end
end
