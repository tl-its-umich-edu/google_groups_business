## Common test setup / utilities



#require_relative '../groups_admin'

require 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'shoulda'
require 'rack/test'

#class TestHelper
module TestHelper

  #include Rack::Test::Methods

  # convenience function to create a reasonable group name
  def create_group_name(root)
    "#{root}@#{TEST_DOMAIN}"
  end

  def new_epoch_time
    sleep 1
    Time.new.to_i
  end


  def create_test_group_configuration
    sleep 1
    group_email = create_group_name "#{@group_name}_#{Time.now.to_i}"

    ng_test = {
        "email": group_email,
        "name": "#{@group_name}: CPM group insert test",
        "description": "This is a group inserted by CPM testing at: #{Time.new.iso8601}"
    }
    return group_email, ng_test
  end

  # see if status has common messages
  def check_error_response(last_response)
    refute_match 'Sinatra doesn&rsquo;t know this ditty',last_response.body,"unmatched url"
  end

end
