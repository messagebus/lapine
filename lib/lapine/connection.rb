require 'bunny'

module Lapine
  class Connection
    attr_reader :conn, :name, :props

    def initialize(name, properties)
      @name = name
      @props = properties.dup
    end

    def exchange
      reconnect unless conn && conn.connected?
      @exchange
    end

    def reconnect
      connection_props = Lapine.config.connection_properties[props.delete(:connection)]
      @conn = Bunny.new(connection_props)
      conn.start
      channel = conn.create_channel
      exchange_type = props.delete(:type)
      @exchange = Bunny::Exchange.new(channel, exchange_type, name, props)
    end
  end
end
