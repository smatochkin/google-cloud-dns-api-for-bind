#
# HTTP Request helpers
#
module Requests
  #
  # JSON parse helper
  #
  # Use:
  #  # Include in spec/spec_helper.rb
  #  config.include Requests::JsonHelpers, :type => :controller
  #
  # Use in expect statements
  #  expect(json).to have_key('test_key')
  module JsonHelpers
    def json
      @json ||= JSON.parse(last_response.body)
    end
  end

  #
  # Authentication helpers
  #
  # Usage: 
  #  # spec/spec_helper.rb
  #  config.include AuthHelpers, :type => :controller
  #  
  #  # setting authorization headers for the given user
  #  before(:each) { authWithUser(user) }
  #
  #  # clearing any authorization headers
  #  before(:each) { clearToken }
  module AuthHelpers
    def authWithUser (user)
      authorize 'admin', 'password'
    end
  end
  
end
