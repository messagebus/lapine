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

    def channels_by_exchange_id
      @channels_by_exchange_id ||= {}
    end

    def register_channel(object_id, channel)
      channels_by_exchange_id[object_id] = channel
    end

    def cleanup_exchange(id)
      $stderr.puts "Closing channel for exchange #{id}, thread: #{Thread.current.object_id}"
      return unless channels_by_exchange_id[id]
      channel = channels_by_exchange_id[id]
      channel.connection.logger.info "Closing channel for exchange #{id}, thread: #{Thread.current.object_id}"
      channel.close
      channels_by_exchange_id[id] = nil
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
        @conn = Bunny.new(connection_props_for(name)).tap do |conn|
          conn.start
        end
      end
    end

    def close_connections!
      @active_connections.values.map(&:close)
      @active_connections = {}
      Thread.current[:lapine_exchanges] = nil
    end

    def connection_props_for(name)
      return unless connection_properties[name]
      connection_properties[name].dup.tap do |props|
        if defined?(Rails)
          props.merge!(logger: Rails.logger)
        end
      end
    end
  end
end
