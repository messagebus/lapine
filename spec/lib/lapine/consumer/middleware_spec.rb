require 'spec_helper'
require 'lapine/consumer/dispatcher'
require 'lapine/consumer/middleware'

RSpec.describe Lapine::Consumer::Middleware do
  class MiddlewareAddLetter
    def initialize(app, letter)
      @app = app
      @letter = letter
    end

    def call(message)
      message['letter'] = @letter
      @app.call(message)
    end
  end

  class MiddlewareCopyLetter
    def initialize(app)
      @app = app
    end

    def call(message)
      message['middleware.copy_letter.ran'] = true
      message['duplicate_letter'] = message['letter']
      @app.call(message)
    end
  end

  class RaisingMiddleware
    def initialize(app)
      @app = app
    end

    def call(_message)
      raise StandardError.new('Raise')
    end
  end

  class CatchingMiddleWare
    def initialize(app)
      @app = app
    end

    def call(message)
      @app.call(message)
    rescue StandardError => e
      message['error_message'] = e.message
    end
  end

  let(:metadata) { double('metadata', ack: true) }
  let(:payload) { '{}' }
  let(:message) { Lapine::Consumer::Message.new(payload, metadata, nil) }

  describe '.add' do
    before do
      Lapine::Consumer::Middleware.tap do |middleware|
        middleware.add MiddlewareAddLetter, 'f'
      end
    end

    it 'is adds letter to hash' do
      Lapine::Consumer::Middleware.app.call(message) do |message|
        expect(message['letter']).to eq('f')
      end
    end

    context 'when duplicate middleware is added' do
      it 'raises' do
        expect {
          Lapine::Consumer::Middleware.tap do |middleware|
            middleware.add MiddlewareAddLetter, 'f'
          end
        }.to raise_error(Lapine::DuplicateMiddleware)
      end
    end
  end

  describe '.delete' do
    let(:registry) { Lapine::Consumer::Middleware.registry }

    before do
      Lapine::Consumer::Middleware.tap do |middleware|
        middleware.add MiddlewareAddLetter, 'f'
      end
    end

    it 'removes register that matches class name' do
      expect(registry.index_of(MiddlewareAddLetter)).to be
      Lapine::Consumer::Middleware.delete(MiddlewareAddLetter)
      expect(registry.index_of(MiddlewareAddLetter)).not_to be
    end
  end

  describe 'error handling' do
    describe 'with default middleware' do
      let(:error) { StandardError.new('doh') }

      it 'runs through the dispatcher error_handler' do
        errors = []
        Lapine::Consumer::Dispatcher.error_handler = ->(e, data, md) {
          errors << [e, data, md]
        }
        Lapine::Consumer::Middleware.app.call(message) { raise error }
        expect(errors).to include([error, message.payload, message.metadata])
      end
    end

    describe 'with custom middleware' do
      before do
        Lapine::Consumer::Middleware.tap do |middleware|
          middleware.add CatchingMiddleWare
          middleware.add RaisingMiddleware
        end
      end

      it 'catches error' do
        Lapine::Consumer::Middleware.app.call(message)
        expect(message['error_message']).to eq('Raise')
      end

      it 'halts execution' do
        expectation = double(called: true)
        Lapine::Consumer::Middleware.app.call(message) do
          expectation.called
        end
        expect(expectation).not_to have_received(:called)
      end
    end
  end

  describe '.add_before' do
    before do
      Lapine::Consumer::Middleware.tap do |middleware|
        middleware.add MiddlewareAddLetter, 'f'
        middleware.add_before MiddlewareAddLetter, MiddlewareCopyLetter
      end

      it 'prepends middleware' do
        Lapine::Consumer::Middleware.app.call(message) do |message|
          expect(message['letter']).to eq('f')
          expect(message['duplicate_letter']).to be nil
          expect(message['middleware.copy_letter.ran']).to be true
        end
      end
    end
  end

  context '.add_after' do
    before do
      Lapine::Consumer::Middleware.tap do |middleware|
        middleware.add MiddlewareAddLetter, 'f'
        middleware.add_after MiddlewareAddLetter, MiddlewareCopyLetter
      end

      it 'prepends middleware' do
        Lapine::Consumer::Middleware.app.call(message) do |message|
          expect(message['letter']).to eq('f')
          expect(message['duplicate_letter']).to be 'f'
          expect(message['middleware.copy_letter.ran']).to be true
        end
      end
    end
  end
end
