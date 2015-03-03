module Lapine
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
end
