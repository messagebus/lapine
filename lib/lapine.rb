require 'lapine/version'
require 'bunny'

module Lapine
  class UndefinedConnection < StandardError;
  end
  class UndefinedExchange < StandardError;
  end

  class Configuration
    def connections
      @connections ||= {}
    end

    def connection_properties
      @connection_properties ||= {}
    end

    def exchanges
      @exchanges ||= {}
    end

    def exchange_properties
      @exchange_properties ||= {}
    end
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.add_connection(name, properties)
    config.connection_properties[name] = properties
  end

  def self.add_exchange(name, properties)
    connection = properties[:connection]
    raise UndefinedConnection unless connection
    raise UndefinedConnection unless config.connection_properties[connection]
    config.exchange_properties[name] = properties
  end

  def self.find_exchange(name)
    exchange = config.exchange_properties[name]
    raise UndefinedExchange unless exchange
    return config.exchanges[name] if config.exchanges[name]
    config.exchanges[name] = create_exchange(name, exchange.dup)
    config.exchanges[name]
  end

  private

  def self.create_exchange(name, exchange_props)
    connection_props = config.connection_properties[exchange_props.delete(:connection)]
    conn = Bunny.new(connection_props)
    conn.start
    channel = conn.create_channel
    exchange_type = exchange_props.delete(:type)
    Bunny::Exchange.new(channel, exchange_type, name, exchange_props)
  end

end
