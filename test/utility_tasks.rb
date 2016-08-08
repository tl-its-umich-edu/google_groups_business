#require 'rubygems'

#ENV['RACK_ENV'] = 'test'
# this must be early
require_relative '../groups_admin'

require 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'shoulda'
require 'rack/test'
#require 'webmock/minitest'

require 'sinatra'


class AppGroupsTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  TEST_DOMAIN='discussions-dev.its.umich.edu'

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @group_name = 'GGB_CPM_TL_test_group'
    #@eternal_member = "ggb-cpm-test-eternal-member"
    @eternal_member = 'ggb-cpm-test-eternal-member@umich.edu'
    @eternal_group_name = "ggb-cpm-eternal"
    @eternal_group_email = "#{@eternal_group_name}@discussions-dev.its.umich.edu"
    @temporary_group_email = "GGB-CPM-TEST-GROUP-MEMBERS@discussions-dev.its.umich.edu"
    #get "/groups/GGB-CPM-TEST-ETERNAL-MEMBER@umich.edu/members"
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end


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

  ### verify status page

  context "STATUS PAGE" do

    # Can add additional setup / teardown with each context
    should "get json format when explicit" do
      get '/status.json'
      assert last_response.ok?
      assert_equal 'application/json', last_response.header['Content-Type'], "content type is json"
    end

    should "get json format by default" do
      get '/status'
      assert last_response.ok?
      assert_equal 'application/json', last_response.header['Content-Type'], "content type is json"
    end

    should "get html format when explict" do
      get '/status.html'
      assert last_response.ok?
      assert_match "text/html", last_response.header['Content-Type'], "content type is html"
    end

    should "get cool status content" do
      get '/status.json'
      assert last_response.ok?
      json_body = JSON.parse(last_response.body)
      refute_nil json_body, "result should exist"
      refute_nil json_body['current_time'], "should have entry for time"
    end

  end


  ## test top level groups functionallity
  context "GROUPS" do

    setup do
    end


    should "list existing groups" do
      get '/groups'
      assert last_response.ok?
      body_json = JSON.parse(last_response.body)
      assert_operator body_json['groups'].length, :>, 2, "should have at least 3 groups."
    end


    should "get group information" do
      get "/groups/#{@eternal_group_email}"
#      puts "get group info /groups/#{@eternal_group_email} #{last_response.inspect}"
      assert last_response.ok?, "get group info"
    end


    should "delete group" do

      group_email, ng_test = create_test_group_configuration

      put "/groups/#{group_email}", ng_test
      assert_equal 200, last_response.status, "must have group to delete"

      delete "/groups/#{group_email}"
      assert last_response.ok?, "can delete group"

      get "/groups/#{group_email}"
      assert_equal 404, last_response.status, "group must no longer exist"

    end

  end


  context "MEMBERS" do

    should "list all members" do
      url = "/groups/#{@eternal_group_email}/members"
      get url
      assert last_response.ok?, "eternal group always has members"
      response_ruby = JSON.parse(last_response.body)
      assert_operator response_ruby['members'].length, :>, 0, "should have at least 1 member"
    end

    should "list member" do
      url = "/groups/#{@eternal_group_email}/members/#{@eternal_member}"
      get url
      assert last_response.ok?, "find eternal member"
      response_ruby = JSON.parse(last_response.body)
      assert_equal 6, response_ruby.length, "proper number of keys in member data"
      assert_match /#{Regexp.escape @eternal_member}/i, response_ruby['email'], "response has correct email"
    end

    # member = {
    #     'email': @common_fake,
    #     'role': 'OWNER'
    # }
    #
    # # clear out the fake user if it is already there
    # begin
    #   @s.delete_member ETERNAL_GROUP, @common_fake
    # rescue => exp
    # end
    #
    # member_result = @s.insert_member ETERNAL_GROUP, member
    # refute_nil member_result, "should insert user #{@common_fake} into #{ETERNAL_GROUP}"


    should "add member: new" do
      new_id = new_epoch_time

      # create group if it doesn't exist

      put "/groups/#{@temporary_group_email}"

      status = last_response.status
      puts "add member: new status code: #{status}"
      assert status == 201 || status == 422, "ensure member test group exists"

      #use_args = [args[1], {'email': args[2], 'role': args[3]}]

      url = "/groups/#{@temporary_group_email}/members/GGB-CPM-TEST-MEMBER-#{new_id}@nowhere.edu"

      puts "add member: new: url: #{url}"
      put url

      puts "last_response: #{last_response.inspect}"
      assert last_response.ok?, "new member addition"


      fail "not yet finished"
    end

    should "add member: existing " do
      skip "soon"
      fail "not yet implemented"
    end

    should "add member: absurd" do
      skip "soon"
      fail "not yet implemented"
    end


    should_eventually "delete member"
    should_eventually "update member"
  end

  context "archive" do
    should_eventually "add email"
  end

end
