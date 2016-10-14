require_relative '../groups_admin'
require_relative 'test_helper'

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
  include TestHelper

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

  ## test top level groups functionallity
  context "GROUPS" do

    setup do
      basic_authorize 'admin', 'admin'
    end

    should "list existing groups" do

      get '/groups'
      assert last_response.ok?
      body_json = JSON.parse(last_response.body)
      assert_operator body_json['groups'].length, :>, 2, "should have at least 3 groups."
    end

    should "list existing groups (trailing slash)" do
      get '/groups/'
      assert last_response.ok?
      body_json = JSON.parse(last_response.body)
      assert_operator body_json['groups'].length, :>, 2, "should have at least 3 groups."
    end

    should "create new group" do

      group_email, ng_test = create_test_group_configuration

      put "/groups/#{group_email}", ng_test
      assert last_response.ok?

    end

    should "NOT create new group if group id doesn't match" do

      group_email, ng_test = create_test_group_configuration

      put "/groups/#{group_email}.XXX", ng_test
      refute last_response.ok?, "inconsistant group email"

    end

    should "not create duplicate group" do

      group_email, ng_test = create_test_group_configuration

      put "/groups/#{group_email}", ng_test
      assert_equal 200, last_response.status

      ## test for duplicate error
      put "/groups/#{group_email}", ng_test
      assert_equal 409, last_response.status

    end

    should "create by post should fail" do

      group_email, ng_test = create_test_group_configuration

      post "/groups/#{group_email}", ng_test
      assert_equal 501, last_response.status, "post not implemented for group create"
    end


    # def group_info(args)
    #
    #   config = {
    #       :args => args,
    #       :required_args => 2,
    #       :method_symbol => :get_group_info,
    #       :handle_result => Proc.new { |result|
    #         puts "group_info:"
    #         puts "result.inspect: #{result.inspect}"
    #         result
    #       },
    #       :service_name => 'ADMIN_DIRECTORY'
    #   }
    #
    #   run_request(config, args[1])
    # end
    should "get group information" do
      get "/groups/#{@eternal_group_email}"
      assert last_response.ok?, "get group info"
    end

    should "not get group information for bad group" do
      get "/groups/HippyHappyDays"
      assert_equal 404, last_response.status, "group does not exist"
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


    should "not delete group that doesn't exist" do

      # get rid of the group if it exists.
      delete "/groups/MyNameIsLegend"

      get "/groups/MyNameIsLegend"
      assert_equal 404, last_response.status, "group must no longer exist"

    end

    should_eventually "update setting information" do

    end

  end

end
