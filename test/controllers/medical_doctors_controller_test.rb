require 'test_helper'

class MedicalDoctorsControllerTest < ActionController::TestCase
  setup do
    @medical_doctor = medical_doctors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:medical_doctors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create medical_doctor" do
    assert_difference('MedicalDoctor.count') do
      post :create, medical_doctor: { name: @medical_doctor.name, phone_number: @medical_doctor.phone_number }
    end

    assert_redirected_to medical_doctor_path(assigns(:medical_doctor))
  end

  test "should show medical_doctor" do
    get :show, id: @medical_doctor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @medical_doctor
    assert_response :success
  end

  test "should update medical_doctor" do
    patch :update, id: @medical_doctor, medical_doctor: { name: @medical_doctor.name, phone_number: @medical_doctor.phone_number }
    assert_redirected_to medical_doctor_path(assigns(:medical_doctor))
  end

  test "should destroy medical_doctor" do
    assert_difference('MedicalDoctor.count', -1) do
      delete :destroy, id: @medical_doctor
    end

    assert_redirected_to medical_doctors_path
  end
end
