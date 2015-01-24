module Lapine
  module Consumer
    class Environment
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def load!
        set_environment
        load_rails
        require_from_config
      end

      def set_environment
        ENV['RAILS_ENV'] ||= 'development'
        ENV['RACK_ENV'] ||= ENV['RAILS_ENV']
      end

      def load_rails
        begin
          require 'rails'
          if ::Rails.application.respond_to?(:eager_load)
            require File.expand_path('config/environment.rb')
            ::Rails.application.eager_load!
          else
            require File.expand_path('config/application.rb')
            ::Rails::Application.initializer "lapine.load_rails" do
              ::Rails.application.config.eager_load = true
            end
            require File.expand_path('config/environment.rb')
          end
        rescue LoadError
        end
      end

      def require_from_config
        if config.require
          config.require.each do |file|
            require File.expand_path(file)
          end
        end
      end
    end
  end
end
