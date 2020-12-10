require 'bundler/setup'
require 'ynetaddr'
require 'json'
require 'yaml'

class TestObj
  def to_ipv4addr
    Net::IPv4Addr.new('44.55.66.77')
  end

  def to_ipv4ifaddr
    Net::IPv4Addr.new('44.55.66.77/24')
  end

  def to_ipv4net
    Net::IPv4Addr.new('44.55.66.0/24')
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
