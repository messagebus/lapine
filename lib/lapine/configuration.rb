module Lapine
  class Configuration
    def initialize
      @active_connections = {}
    end

    def connections
      @connections ||= {}
    end

    def connection_properties
      @connection_properties ||= {}
    end

    def exchanges
      Thread.current[:lapine_exchanges] ||= {}
    end

    def exchange_properties
      @exchange_properties ||= {}
    end

    def active_connection(name)
      conn = @active_connections[name]
      return conn if (conn && conn.connected?)

      @active_connections[name] = begin
        connection_props = Lapine.config.connection_properties[name]
        @conn = Bunny.new(connection_props).tap do |conn|
          conn.start
        end
      end
    end

    def close_connections!
      @active_connections.values.map(&:close)
      @active_connections = {}
      Thread.current[:lapine_exchanges] = nil
    end
  end
end
