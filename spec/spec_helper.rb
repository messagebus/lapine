require 'lapine'
require 'pry'
require 'rspec/mocks'
require 'lapine/consumer/dispatcher'
require 'lapine/consumer/middleware'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |f|
  require f
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.order = :random # use --seed NNNN
  Kernel.srand config.seed

  config.before :each do
    Lapine::Consumer::Dispatcher.error_handler = nil
    Lapine.instance_variable_set(:@config, nil)
    Lapine::Consumer::Middleware.instance_variable_set(:@registry, nil)
    Thread.current.thread_variable_set(:lapine_exchanges, nil)
  end

  config.after :each do
    Lapine.close_connections!
  end
end
