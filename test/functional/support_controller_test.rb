require 'test_helper'

class SupportControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get section" do
    get :section
    assert_response :success
  end

  test "should get page" do
    get :page
    assert_response :success
  end

end
