require 'test_helper'

class FirstRespondersControllerTest < ActionController::TestCase
  setup do
    @first_responder = first_responders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:first_responders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create first_responder" do
    assert_difference('FirstResponder.count') do
      post :create, first_responder: {  }
    end

    assert_redirected_to first_responder_path(assigns(:first_responder))
  end

  test "should show first_responder" do
    get :show, id: @first_responder
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @first_responder
    assert_response :success
  end

  test "should update first_responder" do
    patch :update, id: @first_responder, first_responder: {  }
    assert_redirected_to first_responder_path(assigns(:first_responder))
  end

  test "should destroy first_responder" do
    assert_difference('FirstResponder.count', -1) do
      delete :destroy, id: @first_responder
    end

    assert_redirected_to first_responders_path
  end
end
