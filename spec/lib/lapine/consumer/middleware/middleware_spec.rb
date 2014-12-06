require 'spec_helper'
require 'lapine/consumer/middleware/middleware'

RSpec.describe Lapine::Consumer::Middleware do

  it 'yields chain' do
    expect { |b| Lapine::Consumer::Middleware.chain(&b) }.to yield_with_args(Lapine::Consumer::Middleware::Chain)
  end

  it 'returns chain' do
    expect(Lapine::Consumer::Middleware.chain).to be_a Lapine::Consumer::Middleware::Chain
  end

end
