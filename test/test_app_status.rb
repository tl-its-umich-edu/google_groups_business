#require 'rubygems'

#ENV['RACK_ENV'] = 'test'
# this must be early
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
# #require 'webmock/minitest'
#
# require 'sinatra'


class StatusAppGroupsTest < Minitest::Test

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


  # # convenience function to create a reasonable group name
  # def create_group_name(root)
  #   "#{root}@#{TEST_DOMAIN}"
  # end
  #
  # def new_epoch_time
  #   sleep 1
  #   Time.new.to_i
  # end


  # def create_test_group_configuration
  #   sleep 1
  #   #group_email = self.class.create_group_name "#{@group_name}_#{Time.now.to_i}"
  #   group_email = create_group_name "#{@group_name}_#{Time.now.to_i}"
  #
  #   ng_test = {
  #       "email": group_email,
  #       "name": "#{@group_name}: CPM group insert test",
  #       "description": "This is a group inserted by CPM testing at: #{Time.new.iso8601}"
  #   }
  #   return group_email, ng_test
  # end

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
      body_as_ruby = JSON.parse(last_response.body)
      refute_nil body_as_ruby, "result should exist"
      refute_nil body_as_ruby['current_time'], "have entry for time"
      refute_nil body_as_ruby['server'], "have entry for server"
    end

    should "respond to ping.json" do
      get '/status/ping.json'
      assert last_response.ok?, 'requested status/ping'
      assert_equal 'application/json', last_response.header['Content-Type'], "content type is json"
    end

    should "respond to ping" do
      get '/status/ping'
      assert last_response.ok?, 'requested status/ping'
      assert_equal 'application/json', last_response.header['Content-Type'], "content type is json"
    end

    should "respond to ping.html" do
      get '/status/ping.html'
      assert last_response.ok?, 'requested status/ping'
      assert_match 'text/html', last_response.header['Content-Type'], "content type is html"
    end

  end


end
