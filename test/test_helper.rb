## Common test setup / utilities

require 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'shoulda'
require 'rack/test'

TEST_DOMAIN='discussions-dev.its.umich.edu'
EMAIL_INSERT_TEST_GROUP="ggb-test-group-insert@discussions-dev.its.umich.edu"

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
    refute_match 'Sinatra doesn&rsquo;t know this ditty', last_response.body, "unmatched url"
  end


  #From: "Alice Smith" <alice@example.com>
  def create_test_email(group_id, from_name, from_email)
    # Format an RFC822 message
    now = Time.now
    message_id = "#{now.to_f}-#{group_id}"
    message_date = now.strftime '%a, %d %b %Y %T %z'
    message = <<-EOF
Message-ID: <#{message_id}>
Date: #{message_date}
To: #{group_id}
From: "#{from_name}" <#{from_email}>
Subject: Groups Migration API Test #{now.iso8601}

This is a test email generated at #{now.iso8601}
    EOF
  end


end
