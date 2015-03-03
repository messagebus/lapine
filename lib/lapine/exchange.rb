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

    def connected?
      @exchange.channel.connection.connected?
    end

    def exchange
      @exchange ||= begin
        conn = Lapine.config.active_connection(connection_name)
        channel = conn.create_channel
        Bunny::Exchange.new(channel, exchange_type, name, props)
      end
    end
  end
end
