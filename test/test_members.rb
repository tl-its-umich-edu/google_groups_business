require_relative '../groups_admin'
require_relative 'test_helper'

require 'sinatra'

class MembersAppGroupsTest < Minitest::Test

  include TestHelper

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  #TEST_DOMAIN='discussions-dev.its.umich.edu'

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

  # utility function to be used from other functions.  Assumes that this is a valid request.
  def get_members(url)
    get url
    check_error_response(last_response)
    assert last_response.ok?, "get list of member from extant group"
    JSON.parse(last_response.body)['members']
  end

  # utility function to delete member.  Assumes this is a valid request.
  def delete_member(url)
    delete url
    assert last_response.ok?, "deleting extant member"
    check_error_response(last_response)
  end

  context "MEMBERS" do

    should "list all members" do
      # assume eternal_group_email exists
      url = "/groups/#{@eternal_group_email}/members"
      get url
      assert last_response.ok?, "eternal group always has members"
      response_ruby = JSON.parse(last_response.body)
      assert_operator response_ruby['members'].length, :>, 0, "should have at least 1 member"
    end

    should "add member: new, default role" do
      new_id = new_epoch_time

      ## create group if it doesn't exist
      url = "/groups/#{@temporary_group_email}"
      put url

      status = last_response.status
      assert status == 201 || status == 422, "ensure member test group exists"

      url = "/groups/#{@temporary_group_email}/members/GGB-CPM-TEST-MEMBER-#{new_id}@nowhere.edu"

      put url
      check_error_response(last_response)

      assert last_response.ok?, "new member addition"
      body_ruby = JSON.parse last_response.body
      assert_match "MEMBER", body_ruby['role']

    end

    should "add member: with OWNER role" do
      new_id = new_epoch_time

      ## create group if it doesn't exist
      url = "/groups/#{@temporary_group_email}"
      put url

      status = last_response.status
      assert status == 201 || status == 422, "ensure member test group exists"

      url = "/groups/#{@temporary_group_email}/members/GGB-CPM-TEST-MEMBER-#{new_id}@nowhere.edu?role=OWNER"

      put url
      check_error_response(last_response)

      assert last_response.ok?, "new member addition"
      body_ruby = JSON.parse last_response.body
      assert_match "OWNER", body_ruby['role']
    end

    should "not add member: with invalid role" do
      new_id = new_epoch_time

      ## create group if it doesn't exist
      url = "/groups/#{@temporary_group_email}"
      put url

      status = last_response.status
      assert status == 201 || status == 422, "ensure member test group exists"

      url = "/groups/#{@temporary_group_email}/members/GGB-CPM-TEST-MEMBER-#{new_id}@nowhere.edu?role=INVALID"
      put url

      refute last_response.ok?, "invalid role should not work"
    end


    should "add member: duplicate" do
      new_id = new_epoch_time

      ## create group if it doesn't exist
      url = "/groups/#{@temporary_group_email}"
      put url
      check_error_response(last_response)

      status = last_response.status
      assert status == 201 || status == 422, "ensure member test group exists"

      url = "/groups/#{@temporary_group_email}/members/GGB-CPM-TEST-MEMBER-#{new_id}@nowhere.edu"

      put url
      check_error_response(last_response)
      assert status == 201 || status == 422, "ensure member is in group"

      assert last_response.ok?, "new member addition"

      put url
      check_error_response(last_response)
      assert status == 422, "ensure entry is recognized as a duplicate"

    end

    should "delete member" do

      new_id = new_epoch_time
      url = "/groups/#{@temporary_group_email}/members/GGB-CPM-TEST-MEMBER-#{new_id}@nowhere.edu"

      current = get_members "/groups/#{@temporary_group_email}/members"
      members_before = current.length

      put url
      check_error_response(last_response)
      new = get_members "/groups/#{@temporary_group_email}/members"
      members_new = new.length

      assert_equal members_before + 1, members_new, "add 1 member"

      delete_member url

      after = get_members "/groups/#{@temporary_group_email}/members"
      members_after = after.length
      assert_equal members_before, members_after, "delete 1 member"

    end
  end

end
