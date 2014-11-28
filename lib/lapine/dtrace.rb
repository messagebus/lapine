require 'usdt'

module Lapine
  class DTrace
    attr_reader :provider, :probes

    def initialize
      @provider = USDT::Provider.create(:ruby, :lapine)

      @probes = {
        # args: Class name, payload
        dispatch_enter: provider.probe(:dispatch, :enter, :string, :string),
        # args: Class name, payload
        dispatch_return: provider.probe(:dispatch, :return, :string, :string),
      }
    end

    def self.provider
      @provider ||= new.tap do |p|
        p.provider.enable
      end
    end

    def self.fire!(probe_name, *args)
      raise "Unknown probe: #{probe_name}" unless self.provider.probes[probe_name]
      probe = self.provider.probes[probe_name]
      probe.fire(*args) if probe.enabled?
    end
  end
end
