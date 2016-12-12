require 'test_helper'

class DataCentersControllerTest < ActionController::TestCase
  setup do
    @data_center = data_centers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_centers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create data_center" do
    assert_difference('DataCenter.count') do
      post :create, data_center: { is_simulator: @data_center.is_simulator, name: @data_center.name }
    end

    assert_redirected_to data_center_path(assigns(:data_center))
  end

  test "should show data_center" do
    get :show, id: @data_center
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @data_center
    assert_response :success
  end

  test "should update data_center" do
    patch :update, id: @data_center, data_center: { is_simulator: @data_center.is_simulator, name: @data_center.name }
    assert_redirected_to data_center_path(assigns(:data_center))
  end

  test "should destroy data_center" do
    assert_difference('DataCenter.count', -1) do
      delete :destroy, id: @data_center
    end

    assert_redirected_to data_centers_path
  end
end
