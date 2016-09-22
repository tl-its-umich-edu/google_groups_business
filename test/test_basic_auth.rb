ENV['RACK_ENV'] = 'test'
require_relative '../groups_admin'
require_relative 'test_helper'

require 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'shoulda'
require 'rack/test'
require 'sinatra'

class BasicAuthTest < Minitest::Test

  include Rack::Test::Methods
  include TestHelper

  def app
    Sinatra::Application
  end

  context "PROTECTED" do
    should "test_without_authentication" do
      get '/test/protected'
      assert_equal 401, last_response.status
    end

    should "test_with_bad_credentials" do
      basic_authorize 'bad', 'boy'
      get '/test/protected'
      assert_equal 401, last_response.status
    end

    should "test_with_proper_credentials" do
      basic_authorize 'upstart', 'ohcrap'
      get '/test/protected'
      assert_equal 200, last_response.status
      assert_equal "Welcome, authenticated!", last_response.body
    end
  end

  context "UNPROTECTED" do

    should "test_unprotected_without_credentials" do
      get '/test/unprotected'
      assert_equal 200, last_response.status
      assert_equal "Welcome, ignoring authentication!", last_response.body
    end

    should "test_unprotected_with_credentials" do
      basic_authorize 'upstart', 'ohcrap'
      get '/test/unprotected'
      assert_equal 200, last_response.status
      assert_equal "Welcome, ignoring authentication!", last_response.body
    end

    should "test_unprotected_with_bad_credentials" do
      basic_authorize 'yougotta', 'bekidding'
      get '/test/unprotected'
      assert_equal 200, last_response.status
      assert_equal "Welcome, ignoring authentication!", last_response.body
    end
  end
end

