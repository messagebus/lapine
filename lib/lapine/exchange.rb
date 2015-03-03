require 'bunny'

module Lapine
  class Exchange
    attr_reader :conn, :name, :props, :connection_name, :exchange_type

    def initialize(name, properties)
      @name = name
      @props = properties.dup
      @connection_name = props.delete(:connection)
      @exchange_type = props.delete(:type)
      ObjectSpace.define_finalizer(self, proc { |id| Lapine.config.cleanup_exchange(id) })
    end

    def connected?
      @exchange.channel.connection.connected? &&
        @exchange.channel.open?
    end

    def exchange
      @exchange ||= begin
        conn = Lapine.config.active_connection(connection_name)
        conn.logger.info "Creating channel for #{self.object_id}, thread: #{Thread.current.object_id}"
        channel = conn.create_channel
        Lapine.config.register_channel(self.object_id, channel)
        Bunny::Exchange.new(channel, exchange_type, name, props)
      end
    end

    def close
      @exchange.channel.close
    end
  end
end
