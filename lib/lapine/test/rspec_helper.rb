require 'lapine/test/exchange'

module Lapine
  module Test
    module RSpecHelper
      def self.setup(_example = nil)
        RSpec::Mocks::AllowanceTarget.new(Lapine::Exchange).to(
          RSpec::Mocks::Matchers::Receive.new(:new, ->(name, properties) {
            Lapine::Test::Exchange.new(name, properties)
          })
        )
      end

      def self.teardown
        Lapine.close_connections!
      end
    end
  end
end
