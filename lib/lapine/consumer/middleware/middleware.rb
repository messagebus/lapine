require 'lapine/consumer/middleware/chain'

module Lapine
  module Consumer
    module Middleware
      def self.chain &block
        @chain ||= ::Lapine::Consumer::Middleware::Chain.new
        yield @chain if block_given?
        @chain
      end
    end
  end
end
