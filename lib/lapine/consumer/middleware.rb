require 'lapine/consumer/middleware/error_handler'
require 'lapine/consumer/middleware/message_ack_handler'
require 'lapine/consumer/middleware/json_decoder'

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
      # A Register of a middleware class that messages will be passed through
      # on the way to being dispatched.
      class Register < Struct.new(:klass, :args)
        def create_new(app)
          klass.new(app, *args)
        end
      end

      DEFAULT_MIDDLEWARE = [
        Register.new(MessageAckHandler),
        Register.new(ErrorHandler),
        Register.new(JsonDecoder)
      ].freeze

      class << self
        def add(klass, *args)
          registry << [klass, args]
        end

        def add_before(before_klass, klass, *args)
          idx = registry.index_of(before_klass)
          raise MiddlewareNotFound.new("#{before_klass} not registered in Lapine middleware") unless idx
          registry.insert(idx, klass, args)
        end

        def add_after(after_klass, klass, *args)
          idx = registry.index_of(after_klass)
          raise MiddlewareNotFound.new("#{after_klass} not registered in Lapine middleware") unless idx
          registry.insert(idx + 1, klass, args)
        end

        def delete(klass)
          registry.delete(klass)
        end

        def registry
          @registry ||= Registry.new(DEFAULT_MIDDLEWARE.dup)
        end

        def create_chain(app)
          registry.map { |r| r.create_new(app) }
        end

        def app
          App.new.tap do |app|
            app.chain = create_chain(app)
          end
        end
      end

      class App
        attr_accessor :chain

        def call(message, &block)
          chain << block if block_given?
          current_register = chain.shift
          current_register.call(message) if current_register
        end
      end

      # Registry holds records of each middleware class that is added to the
      # consumer middleware chain.
      class Registry
        include Enumerable

        attr_reader :registry

        def initialize(registry = [])
          @registry = registry
        end

        def all
          registry
        end

        def each(&blk)
          all.each(&blk)
        end

        def delete(klass)
          registry.reject! { |register| register.klass == klass }
        end

        def <<(klass_args)
          insert(-1, klass_args[0], klass_args[1])
        end

        def index_of(klass)
          registry.find_index { |register| register.klass == klass }
        end

        def insert(index, klass, args)
          raise Lapine::DuplicateMiddleware if index_of(klass)
          registry.insert(index, Register.new(klass, args))
        end
      end
    end
  end
end
