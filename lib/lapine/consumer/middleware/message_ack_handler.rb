module Lapine
  module Consumer
    module Middleware
      class MessageAckHandler
        attr_reader :app

        def initialize(app)
          @app = app
        end

        def call(message)
          app.call(message)
          message.metadata.ack
        end
      end
    end
  end
end
