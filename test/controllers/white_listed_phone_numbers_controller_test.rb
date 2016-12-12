require 'test_helper'

class WhiteListedPhoneNumbersControllerTest < ActionController::TestCase
  setup do
    @white_listed_phone_number = white_listed_phone_numbers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:white_listed_phone_numbers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create white_listed_phone_number" do
    assert_difference('WhiteListedPhoneNumber.count') do
      post :create, white_listed_phone_number: { data_center: @white_listed_phone_number.data_center, name: @white_listed_phone_number.name, phone_number: @white_listed_phone_number.phone_number }
    end

    assert_redirected_to white_listed_phone_number_path(assigns(:white_listed_phone_number))
  end

  test "should show white_listed_phone_number" do
    get :show, id: @white_listed_phone_number
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @white_listed_phone_number
    assert_response :success
  end

  test "should update white_listed_phone_number" do
    patch :update, id: @white_listed_phone_number, white_listed_phone_number: { data_center: @white_listed_phone_number.data_center, name: @white_listed_phone_number.name, phone_number: @white_listed_phone_number.phone_number }
    assert_redirected_to white_listed_phone_number_path(assigns(:white_listed_phone_number))
  end

  test "should destroy white_listed_phone_number" do
    assert_difference('WhiteListedPhoneNumber.count', -1) do
      delete :destroy, id: @white_listed_phone_number
    end

    assert_redirected_to white_listed_phone_numbers_path
  end
end
