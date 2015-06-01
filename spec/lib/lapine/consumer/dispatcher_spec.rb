require 'spec_helper'
require 'lapine/consumer/dispatcher'

RSpec.describe Lapine::Consumer::Dispatcher do

  subject(:dispatcher) { Lapine::Consumer::Dispatcher.new(delegate, message) }
  let(:message) do
    Lapine::Consumer::Message.new(json, metadata, logger).tap do |message|
      message['decoded_payload'] = hash
    end
  end

  let(:logger) { double('logger') }
  let(:hash) { {'foo' => 'bar'} }
  let(:json) { Oj.dump(hash) }
  let(:metadata) { double('metadata', routing_key: 'routing_key') }
  let(:delegate) { double('delegate', name: 'ClassName') }

  let(:caught_errors) { [] }

  after do
    Lapine::Consumer::Dispatcher.error_handler = nil
  end

  describe '#delegation' do
    context 'success cases' do
      before do
        expect(logger).to receive(:info).once.with(/Processing(.*)ClassName/)
      end

      context '.handle_lapine_payload method' do
        it 'receives handle_lapine_payload' do
          expect(delegate).to receive(:respond_to?).with(:handle_lapine_payload).and_return(true)
          expect(delegate).to receive(:handle_lapine_payload).once
          dispatcher.dispatch
        end
      end

      context '.perform_async method' do
        it 'receives perform_async' do
          expect(delegate).to receive(:respond_to?).with(:handle_lapine_payload).and_return(false)
          expect(delegate).to receive(:respond_to?).with(:perform_async).and_return(true)
          expect(delegate).to receive(:perform_async).once
          dispatcher.dispatch
        end
      end
    end
  end
end

RSpec.describe Lapine::Consumer::Dispatcher::DefaultErrorHandler do
  let(:payload) { double('payload') }
  let(:metadata) { double('metadata') }

  it 'puts to stderr' do
    expect($stderr).to receive(:puts)
    Lapine::Consumer::Dispatcher::DefaultErrorHandler.new.call(StandardError.new, payload, metadata)
  end
end

