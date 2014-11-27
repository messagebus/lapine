require 'spec_helper'
require 'lapine/consumer/dispatcher'

RSpec.describe Lapine::Consumer::Dispatcher do

  subject(:dispatcher) { Lapine::Consumer::Dispatcher.new(delegate, json, metadata, logger) }
  let(:logger) { double('logger') }
  let(:hash) { {'foo' => 'bar'} }
  let(:json) { Oj.dump(hash) }
  let(:metadata) { double("metadata") }
  let(:delegate) { double("delegate", name: "ClassName") }

  let(:caught_errors) { [] }

  before do
    Lapine::Consumer::Dispatcher.error_handler = ->(error, data) {
      caught_errors << [error, data]
    }
  end

  describe "#delegation" do
    context "success cases" do
      before do
        expect(logger).to receive(:info).once.with(/Processing(.*)ClassName/)
      end

      context ".handle_lapine_payload method" do
        it "receives handle_lapine_payload" do
          expect(delegate).to receive(:respond_to?).with(:handle_lapine_payload).and_return(true)
          expect(delegate).to receive(:handle_lapine_payload).once
          dispatcher.dispatch
        end
      end

      context ".perform_async method" do
        it "receives perform_async" do
          expect(delegate).to receive(:respond_to?).with(:handle_lapine_payload).and_return(false)
          expect(delegate).to receive(:respond_to?).with(:perform_async).and_return(true)
          expect(delegate).to receive(:perform_async).once
          dispatcher.dispatch
        end
      end
    end

    describe 'error cases' do
      context 'with invalid json' do
        let(:json) { 'oh boy I am not actually JSON' }

        it 'notifies new relic with the raw payload' do
          dispatcher.dispatch
          expect(caught_errors).to include([an_instance_of(Oj::ParseError), json])
        end
      end

      context 'with any other error' do
        before { allow(dispatcher).to receive(:do_dispatch).and_raise(ArgumentError) }

        it 'notifies new relic with the parsed json' do
          dispatcher.dispatch
          expect(caught_errors).to include([an_instance_of(ArgumentError), hash])
        end
      end
    end
  end
end

