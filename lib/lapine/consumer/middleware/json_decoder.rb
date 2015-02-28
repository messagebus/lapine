require 'oj'

module Lapine
  module Consumer
    module Middleware
      class JsonDecoder
        attr_reader :app

        def initialize(app)
          @app = app
        end

        def call(message)
          message['decoded_payload'] = Oj.load(message.payload)
          app.call(message)
        end
      end
    end
  end
end
