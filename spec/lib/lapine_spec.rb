require 'spec_helper'
require 'lapine'

RSpec.describe Lapine do
  let(:connection) { double('connection') }
  let(:connection_properties) do
    {
      host: 'someplace.com'
    }
  end

  let(:config) { Lapine::Configuration.new }

  before do
    Lapine.instance_variable_set(:@config, config)
  end

  describe '.add_connection' do
    it 'saves the connection information' do
      Lapine.add_connection 'my-connection', connection_properties
      expect(config.connection_properties['my-connection']).to eq(connection_properties)
    end
  end

  describe '.add_exchange' do
    context 'when connection has been defined' do
      before do
        config.connection_properties['my-connection'] = {}
      end

      it 'saves the exchange information' do
        Lapine.add_exchange 'my-exchange', durable: false, connection: 'my-connection'
        expect(config.exchange_properties['my-exchange']).to eq({
          durable: false,
          connection: 'my-connection'
        })
      end
    end

    context 'when connection has not been defined' do
      it 'raises' do
        expect {
          Lapine.add_exchange 'my-exchange', durable: false, connection: 'my-connection'
        }.to raise_error(Lapine::UndefinedConnection)
      end
    end
  end

  describe '.find_exchange' do
    before do
      allow(Bunny).to receive(:new).and_return(connection)
    end

    context 'when exchange has not been registered' do
      it 'raises' do
        expect {
          Lapine.find_exchange 'non-existent-exchange'
        }.to raise_error(Lapine::UndefinedExchange)
      end
    end

    context 'when exchange has been registered' do
      let(:channel) { double('channel') }
      let(:exchange) { double('exchange') }

      before do
        allow(connection).to receive(:start)
        allow(connection).to receive(:create_channel).and_return(channel)
        allow(Bunny::Exchange).to receive(:new).and_return(exchange)
        config.exchange_properties['my-exchange'] = {connection: 'my-connection', type: :thing, some: 'exchange-property'}
      end

      it 'returns an exchange' do
        expect(Lapine.find_exchange('my-exchange')).to eq(exchange)
      end

      it 'creates the exchange with its configured properties' do
        Lapine.find_exchange('my-exchange')
        expect(Bunny::Exchange).to have_received(:new).with(channel, :thing, 'my-exchange', some: 'exchange-property')
      end

      it 'starts a connection and creates a channel' do
        Lapine.find_exchange('my-exchange')
        expect(connection).to have_received(:start)
        expect(connection).to have_received(:create_channel)
      end

      it 'only creates exchange once' do
        Lapine.find_exchange('my-exchange')
        Lapine.find_exchange('my-exchange')
        expect(connection).to have_received(:start).once
        expect(connection).to have_received(:create_channel).once
      end
    end
  end
end