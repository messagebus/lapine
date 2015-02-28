module Lapine
  module Consumer
    module Middleware
      class ErrorHandler
        attr_reader :app

        def initialize(app)
          @app = app
        end

        def call(message)
          app.call(message)
        rescue StandardError => e
          Lapine::Consumer::Dispatcher.error_handler.call(e, message.payload, message.metadata)
        end
      end
    end
  end
end
