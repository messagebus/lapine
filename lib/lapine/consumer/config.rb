require 'mixlib/cli'
require 'yaml'

module Lapine
  module Consumer
    class Config
      include Mixlib::CLI

      banner 'Usage: lapine consume (options)'

      option :config_file,
        short: '-c CONFIG_FILE',
        long: '--config CONFIG_FILE',
        description: 'YML file with configuration of subscribers',
        required: true

      option :logfile,
        short: '-l LOGFILE',
        long: '--logfile LOGFILE',
        description: 'where to log consumer info',
        required: false

      option :host,
        short: '-H RABBIT_HOST',
        long: '--host RABBIT_HOST',
        description: 'IP or FQDN of RabbitMQ host (default 127.0.0.1)'

      option :port,
        short: '-p RABBIT_PORT',
        long: '--port RABBIT_PORT',
        description: 'port to use with RabbitMQ (default 5672)'

      option :ssl,
        short: '-S',
        long: '--ssl',
        description: 'use ssl to connect (default false)'

      option :vhost,
        short: '-V VHOST',
        long: '--vhost VHOST',
        description: 'RabbitMQ vhost to use (default "/")'

      option :username,
        short: '-U USERNAME',
        long: '--username USERNAME',
        description: 'RabbitMQ user (default guest)'

      option :password,
        short: '-P PASSWORD',
        long: '--password PASSWORD',
        description: 'RabbitMQ password (default guest)'

      option :transient,
        long: '--transient',
        description: 'Auto-delete queues when workers stop',
        default: false

      option :debug,
        long: '--debug',
        description: 'More verbose (and possibly non-threadsafe) log statements',
        default: false

      option :help,
        short: '-?',
        long: '--help',
        description: 'Show this message',
        on: :tail,
        boolean: true,
        show_options: true,
        exit: 0

      def load(argv)
        parse_options argv
        self
      end

      def debug?
        config[:debug]
      end

      def logfile
        config[:logfile]
      end

      def queues
        yaml_config['queues']
      end

      def require
        yaml_config['require'] || []
      end

      def topics
        yaml_config['topics']
      end

      def transient?
        config[:transient]
      end

      def connection_properties
        {
          host: '127.0.0.1',
          port: 5672,
          ssl: false,
          vhost: '/',
          username: 'guest',
          password: 'guest'
        }.merge(file_connection_props)
        .merge(cli_connection_props)
      end

      private

      def file_connection_props
        return {} unless yaml_config['connection']
        yaml_config['connection'].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end

      def cli_connection_props
        {
          host: config[:host],
          port: config[:port] ? config[:port].to_i : nil,
          ssl: config[:ssl],
          vhost: config[:vhost],
          username: config[:username],
          password: config[:password]
        }.delete_if { |k, v| v.nil? }
      end

      def yaml_config
        @yaml ||= YAML.load_file(config[:config_file])
      end
    end
  end
end
