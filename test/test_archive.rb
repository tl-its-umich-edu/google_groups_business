## Test smallest set of functionality required for the CPM email archive migration

######################
### <gid> id of google group, assumed to be email address
### <uid> id of member of group, assumed to be individual email address.
####
# GET /groups/ - list groups
# PUT /groups/<gid> - create new group (PARAMETERS?)
# DELETE /groups/<gid> - get rid of group (and email)

# GET /groups/<gid>/members - get list of members in the group
# PUT /groups/<gid>/members/<uid> (PARAMETERS?) - add a member to group
# POST /groups/<gid>/emailarchive - add email to existing email archive.
######################

require_relative '../groups_admin'

require_relative 'test_helper'

# require 'minitest'
# require 'minitest/autorun'
# require 'minitest/unit'
# require "minitest/reporters"
# Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
#
# require 'shoulda'
# require 'rack/test'
#
require 'sinatra'

EMAIL_INSERT_TEST_GROUP="ggb-test-group-insert@discussions-dev.its.umich.edu"

class ArchiveAppGroupsTest < Minitest::Test

  include TestHelper

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


  TEST_DOMAIN='discussions-dev.its.umich.edu'

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @group_name = 'GGB_CPM_TL_test_group'
    # #@eternal_member = "ggb-cpm-test-eternal-member"
    # @eternal_member = 'ggb-cpm-test-eternal-member@umich.edu'
    @eternal_group_name = "ggb-cpm-eternal"
    @eternal_group_email = "#{@eternal_group_name}@discussions-dev.its.umich.edu"
    @temporary_group_email = "GGB-CPM-TEST-GROUP-MEMBERS@discussions-dev.its.umich.edu"
    # #get "/groups/GGB-CPM-TEST-ETERNAL-MEMBER@umich.edu/members"
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
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

This is a test.
    EOF
  end


  # should "list all members" do
  #   # assume eternal_group_email exists
  #   url = "/groups/#{@eternal_group_email}/members"
  #   get url
  #   assert last_response.ok?, "eternal group always has members"
  #   response_ruby = JSON.parse(last_response.body)
  #   assert_operator response_ruby['members'].length, :>, 0, "should have at least 1 member"
  # end


  context "ARCHIVE" do

    should "add email" do
      group_id = EMAIL_INSERT_TEST_GROUP
      test_email = create_test_email group_id, "Dave Haines", "dlhaines@umich.edu"
      puts "test_email: #{test_email}"
      url = "/groups/#{group_id}/messages"
      post url, test_email
      puts "add email: last_response #{last_response.pretty_inspect}"
      assert last_response.ok?, 'inserting email'
    end

  end

end
