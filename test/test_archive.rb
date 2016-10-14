require_relative '../groups_admin'
require_relative 'test_helper'

require 'sinatra'

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
    basic_authorize "admin","admin"

end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  context "ARCHIVE" do

    should "add email" do
      group_id = EMAIL_INSERT_TEST_GROUP
      test_email = create_test_email group_id, "Dave Haines", "dlhaines@umich.edu"
      #puts "test_email: [#{test_email}]"
      url = "/groups/#{group_id}/messages"
      post url, test_email
      assert last_response.ok?, 'inserting email'
    end

  end

end
