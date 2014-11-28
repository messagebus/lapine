require 'spec_helper'
require 'lapine/consumer/config'

RSpec.describe Lapine::Consumer::Config do
  let(:argv) { %w(-c /path/to/config.yml) }

  subject(:config) { Lapine::Consumer::Config.new }
  let(:config_from_file) { {} }

  before do
    config.load argv
    allow(YAML).to receive(:load_file).with('/path/to/config.yml').and_return(config_from_file)
  end

  describe '#load' do
    it 'returns self' do
      expect(config.load(argv)).to eq(config)
    end
  end

  describe '#connection_properties' do
    before { config.load(argv) }

    let(:connection_properties) { config.connection_properties }

    describe 'host' do
      it 'defaults to 127.0.0.1' do
        expect(connection_properties[:host]).to eq('127.0.0.1')
      end

      context 'with connection info in file' do
        let(:config_from_file) { { 'connection' => { 'host' => '1.1.1.1' } } }

        it 'uses the config file info' do
          expect(connection_properties[:host]).to eq('1.1.1.1')
        end
      end

      context 'with command line arg' do
        let(:argv) { %w(--host 2.2.2.2 -c /path/to/config.yml) }
        let(:config_from_file) { { 'connection' => { 'host' => '1.1.1.1' } } }

        it 'prefers the cli' do
          expect(connection_properties[:host]).to eq('2.2.2.2')
        end
      end
    end

    describe 'port' do
      it 'defaults to 5672' do
        expect(connection_properties[:port]).to eq(5672)
      end

      context 'with connection info in file' do
        let(:config_from_file) { { 'connection' => { 'port' => 5673 } } }

        it 'uses the config file info' do
          expect(connection_properties[:port]).to eq(5673)
        end
      end

      context 'with command line arg' do
        let(:argv) { %w(--port 5674 -c /path/to/config.yml) }
        let(:config_from_file) { { 'connection' => { 'port' => 5673 } } }

        it 'prefers the cli' do
          expect(connection_properties[:port]).to eq(5674)
        end
      end
    end

    describe 'ssl' do
      it 'defaults to false' do
        expect(connection_properties[:ssl]).to be(false)
      end

      context 'with connection info in file' do
        let(:config_from_file) { { 'connection' => { 'ssl' => true } } }

        it 'uses the config file info' do
          expect(connection_properties[:ssl]).to be(true)
        end
      end

      context 'with command line arg' do
        let(:argv) { %w(--ssl -c /path/to/config.yml) }
        let(:config_from_file) { { 'connection' => { 'ssl' => false } } }

        it 'prefers the cli' do
          expect(connection_properties[:ssl]).to be(true)
        end
      end
    end

    describe 'vhost' do
      it 'defaults to /' do
        expect(connection_properties[:vhost]).to eq('/')
      end

      context 'with connection info in file' do
        let(:config_from_file) { { 'connection' => { 'vhost' => '/blah' } } }

        it 'uses the config file info' do
          expect(connection_properties[:vhost]).to eq('/blah')
        end
      end

      context 'with command line arg' do
        let(:argv) { %w(--vhost /argh -c /path/to/config.yml) }
        let(:config_from_file) { { 'connection' => { 'vhost' => '/blah' } } }

        it 'prefers the cli' do
          expect(connection_properties[:vhost]).to eq('/argh')
        end
      end
    end

    describe 'username' do
      it 'defaults to guest' do
        expect(connection_properties[:username]).to eq('guest')
      end

      context 'with connection info in file' do
        let(:config_from_file) { { 'connection' => { 'username' => 'Hrairoo' } } }

        it 'uses the config file info' do
          expect(connection_properties[:username]).to eq('Hrairoo')
        end
      end

      context 'with command line arg' do
        let(:argv) { %w(--username Thlayli -c /path/to/config.yml) }
        let(:config_from_file) { { 'connection' => { 'username' => 'Hrairoo' } } }

        it 'prefers the cli' do
          expect(connection_properties[:username]).to eq('Thlayli')
        end
      end
    end

    describe 'password' do
      it 'defaults to guest' do
        expect(connection_properties[:password]).to eq('guest')
      end

      context 'with connection info in file' do
        let(:config_from_file) { { 'connection' => { 'password' => 'flayrah' } } }

        it 'uses the config file info' do
          expect(connection_properties[:password]).to eq('flayrah')
        end
      end

      context 'with command line arg' do
        let(:argv) { %w(--password pfeffa -c /path/to/config.yml) }
        let(:config_from_file) { { 'connection' => { 'password' => 'flayrah' } } }

        it 'prefers the cli' do
          expect(connection_properties[:password]).to eq('pfeffa')
        end
      end
    end
  end
end
