require 'test_helper'

class HelpPagesControllerTest < ActionController::TestCase
  setup do
    @help_page = help_pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:help_pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create help_page" do
    assert_difference('HelpPage.count') do
      post :create, help_page: {  }
    end

    assert_redirected_to help_page_path(assigns(:help_page))
  end

  test "should show help_page" do
    get :show, id: @help_page
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @help_page
    assert_response :success
  end

  test "should update help_page" do
    put :update, id: @help_page, help_page: {  }
    assert_redirected_to help_page_path(assigns(:help_page))
  end

  test "should destroy help_page" do
    assert_difference('HelpPage.count', -1) do
      delete :destroy, id: @help_page
    end

    assert_redirected_to help_pages_path
  end
end
