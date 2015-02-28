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

      attr_reader :delegate_class, :raw_payload, :metadata, :logger

      def self.error_handler=(handler)
        @error_handler = handler
      end

      def self.error_handler
        @error_handler || DefaultErrorHandler.new
      end

      def initialize(delegate_class, raw_payload, metadata, logger)
        @delegate_class = delegate_class
        @raw_payload = raw_payload
        @metadata = metadata
        @logger = logger
      end

      def dispatch
        Lapine::DTrace.fire!(:dispatch_enter, delegate_class.name, raw_payload)
        json = Oj.load(raw_payload)
        with_timed_logging(json) { do_dispatch(json) }
        Lapine::DTrace.fire!(:dispatch_return, delegate_class.name, raw_payload)
      end

      private

      def with_timed_logging(json)
        time = Time.now
        ret = yield
        time_end = Time.now
        duration = (time_end - time) * 1000
        logger.info "Processing rabbit message handler:#{delegate_class.name} duration(ms):#{duration} payload:#{json.inspect}"
        ret
      end

      def delegate_method_names
        [:handle_lapine_payload, :perform_async]
      end

      def do_dispatch(payload)
        delegate_method_names.each do |meth|
          return delegate_class.send(meth, payload, metadata) if delegate_class.respond_to?(meth)
        end
      end
    end
  end
end
