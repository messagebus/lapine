module Lapine
  module Consumer
    class Message < Hash
      def initialize(payload, metadata, logger)
        super(nil)
        self['payload'] = payload
        self['metadata'] = metadata
        self['logger'] = logger
      end

      def payload
        self['payload']
      end

      def decoded_payload
        self['decoded_payload']
      end

      def metadata
        self['metadata']
      end

      def logger
        self['logger']
      end
    end
  end
end
