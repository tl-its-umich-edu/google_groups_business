require_relative '../groups_admin'
require_relative 'test_helper'

require 'sinatra'

# Only run tests in utilities in special cases.
RUN_TESTS = false
RUN_TESTS = true

class AppGroupsUtilityTest < Minitest::Test

  include Rack::Test::Methods
  include TestHelper

  def app
    Sinatra::Application
  end

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

  if RUN_TESTS
    context "archive" do

      should "generate new dlhaines email" do
        group_id = EMAIL_INSERT_TEST_GROUP
        test_email = create_test_email group_id, "Dave Haines", "dlhaines@umich.edu"
        puts "utility: test_email: "
        puts ">>>>>>>>"
        puts "#{test_email}"
        puts "<<<<<<<<<<<"
      end

      should "generate new pushyami email" do
        group_id = EMAIL_INSERT_TEST_GROUP
        test_email = create_test_email group_id, "Pushyami Gundala", "pushyami@umich.edu"
        puts "utility: test_email: "
        puts ">>>>>>>>"
        puts "#{test_email}"
        puts "<<<<<<<<<<<"
      end

    end
  end
end
