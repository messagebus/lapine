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
      reconnect unless conn && conn.connected?
      @exchange
    end

    def reconnect
      connection_props = Lapine.config.connection_properties[connection_name]
      @conn = Bunny.new(connection_props)
      conn.start
      channel = conn.create_channel
      @exchange = Bunny::Exchange.new(channel, exchange_type, name, props)
    end
  end
end
