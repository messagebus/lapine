require 'oj'
require 'lapine/dtrace'

module Lapine
  module Consumer
    class Dispatcher
      class DefaultErrorHandler
        def call(e, data, _metadata)
          $stderr.puts "Lapine::Dispatcher unable to dispatch, #{e.message}, data: #{data}"
        end
      end

      attr_reader :delegate_class, :message, :payload

      def self.error_handler=(handler)
        @error_handler = handler
      end

      def self.error_handler
        @error_handler || DefaultErrorHandler.new
      end

      def initialize(delegate_class, message)
        @delegate_class = delegate_class
        @message = message
        @payload = message.decoded_payload
      end

      def dispatch
        Lapine::DTrace.fire!(:dispatch_enter, delegate_class.name, message.payload)
        with_timed_logging(payload) { do_dispatch(payload) }
        Lapine::DTrace.fire!(:dispatch_return, delegate_class.name, message.payload)
      end

      private

      def with_timed_logging(json)
        time = Time.now
        ret = yield
        time_end = Time.now
        duration = (time_end - time) * 1000
        message.logger.info "Processing rabbit message handler:#{delegate_class.name} duration(ms):#{duration} payload:#{json.inspect}"
        ret
      end

      def delegate_method_names
        [:handle_lapine_payload, :perform_async]
      end

      def do_dispatch(payload)
        delegate_method_names.each do |meth|
          return delegate_class.send(meth, payload, message.metadata) if delegate_class.respond_to?(meth)
        end
      end
    end
  end
end
