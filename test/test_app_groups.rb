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
require 'webmock/minitest'

require 'sinatra'

class AppGroupsTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
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
      refute_nil json_body['current_time'],"should have entry for time"
    end

  end

  context "groups" do
    should_eventually "list groups"
    should_eventually "get setting information"
    should_eventually "update setting information"
    should_eventually "delete group"
  end

  context "members" do
    should_eventually "add member"
    should_eventually "list member"
    should_eventually "delete member"
  end

  context "archive" do
    should_eventually "add email"
  end

end
