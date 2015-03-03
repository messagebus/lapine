require 'bunny'

module Lapine
  class Exchange
    attr_reader :conn, :name, :props, :connection_name, :exchange_type

    def initialize(name, properties)
      @name = name
      @props = properties.dup
      @connection_name = props.delete(:connection)
      @exchange_type = props.delete(:type)
    end

    def exchange
      check_connection!
      reconnect unless conn
      create_exchange unless current_thread_exchange
      raise Lapine::NilExchange unless current_thread_exchange
      current_thread_exchange
    end

    def check_connection!
      return if conn && conn.connected?
      Thread.current[:lapine_exchanges] = nil
      Thread.current[:lapine_channels] = nil
      @conn = nil
    end

    def reconnect
      connection_props = Lapine.config.connection_properties[connection_name]
      @conn = Bunny.new(connection_props)
      conn.start
    end

    def create_exchange
      current_thread_channel = conn.create_channel
      current_thread_exchange = Bunny::Exchange.new(current_thread_channel, exchange_type, name, props)
    end

    def close!
      conn.close if conn.connected?
    end

    def current_thread_channel
      Thread.current[:lapine_channels] ||= {}
      Thread.current[:lapine_channels][name]
    end

    def current_thread_channel=(channel)
      Thread.current[:lapine_channels] ||= {}
      Thread.current[:lapine_channels][name] = channel
    end

    def current_thread_exchange
      Thread.current[:lapine_exchanges] ||= {}
      Thread.current[:lapine_exchanges][name]
    end

    def current_thread_exchange=(exchange)
      Thread.current[:lapine_exchanges] ||= {}
      Thread.current[:lapine_exchanges][name] = exchange
    end
  end
end
