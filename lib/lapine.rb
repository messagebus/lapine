require 'lapine/version'
require 'lapine/errors'
require 'lapine/configuration'
require 'lapine/exchange'
require 'lapine/publisher'
require 'lapine/annotated_logger'

module Lapine
  def self.config
    @config ||= Configuration.new
  end

  def self.add_connection(name, properties)
    config.connection_properties[name] = properties
  end

  def self.add_exchange(name, properties)
    connection = properties[:connection]
    raise UndefinedConnection.new("No connection for #{name}, properties: #{properties}") unless connection
    raise UndefinedConnection.new("No connection properties for #{name}, properties: #{properties}") unless config.connection_properties[connection]
    config.exchange_properties[name] = properties
  end

  def self.find_exchange(name)
    exchange = config.exchanges[name]
    return exchange.exchange if (exchange && exchange.connected?)

    exchange_configuration = config.exchange_properties[name]
    raise UndefinedExchange.new("No exchange configuration for #{name}") unless exchange_configuration

    config.exchanges[name] = Lapine::Exchange.new(name, exchange_configuration)
    config.exchanges[name].exchange
  end

  def self.close_connections!
    config.close_connections!
  end
end
