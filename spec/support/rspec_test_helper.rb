require 'lapine/test/rspec_helper'

RSpec.configure do |config|
  config.include Lapine::Test::RSpecHelper, with_rspec_helper: true

  config.before :each, :with_rspec_helper do |example|
    Lapine::Test::RSpecHelper.setup(example)
  end

  config.after :each, :with_rspec_helper do
    Lapine::Test::RSpecHelper.teardown
  end
end

