# spec/spec_helper.rb
ENV['RACK_ENV'] = 'test'
 
require 'rack/test'
require_relative 'request_helpers'
require_relative '../server'
 
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Requests::JsonHelpers
  config.include Requests::AuthHelpers

  def app
    DnsService
  end
  
  config.add_setting :zone, :default => 'foo'
  config.add_setting :test_rr, :default => 'www.foo.tld'
end
