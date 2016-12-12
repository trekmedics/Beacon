require 'test_helper'

class SimulationsControllerTest < ActionController::TestCase
  setup do
    @simulation = simulations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:simulations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create simulation" do
    assert_difference('Simulation.count') do
      post :create, simulation: { first_responder_count: @simulation.first_responder_count, incident_count: @simulation.incident_count }
    end

    assert_redirected_to simulation_path(assigns(:simulation))
  end

  test "should show simulation" do
    get :show, id: @simulation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @simulation
    assert_response :success
  end

  test "should update simulation" do
    patch :update, id: @simulation, simulation: { first_responder_count: @simulation.first_responder_count, incident_count: @simulation.incident_count }
    assert_redirected_to simulation_path(assigns(:simulation))
  end

  test "should destroy simulation" do
    assert_difference('Simulation.count', -1) do
      delete :destroy, id: @simulation
    end

    assert_redirected_to simulations_path
  end
end
