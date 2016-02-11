require 'lapine/consumer/middleware/error_handler'
require 'lapine/consumer/middleware/message_ack_handler'
require 'lapine/consumer/middleware/json_decoder'
require 'middlewear'

module Lapine
  module Consumer
    #
    # Consumer middleware can be registered as follows:
    #
    #   Lapine::Consumer::Middleware.add MyClass
    #   Lapine::Consumer::Middleware.add MyClass, argument
    #   Lapine::Consumer::Middleware.add_before MyClass, MyOtherClass, argument
    #   Lapine::Consumer::Middleware.add_after MyClass, MyOtherClass, argument
    #
    # Middleware should follow the pattern:
    #
    #   class MyMiddleware
    #     attr_reader :app
    #
    #     def initialize(app, *arguments)
    #       @app = app
    #     end
    #
    #     def call(message)
    #       # do stuff
    #       app.call(message)
    #     end
    #   end
    #
    module Middleware
      include Middlewear

      DEFAULT_MIDDLEWARE = [
        MessageAckHandler,
        ErrorHandler,
        JsonDecoder
      ].freeze

      DEFAULT_MIDDLEWARE.each do |middleware|
        Lapine::Consumer::Middleware.add(middleware)
      end
    end
  end
end
