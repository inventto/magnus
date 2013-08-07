require 'test_helper'

class RegistrosDePontoControllerTest < ActionController::TestCase
  setup do
    @registro_de_ponto = registros_de_ponto(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:registros_de_ponto)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create registro_de_ponto" do
    assert_difference('RegistroDePonto.count') do
      post :create, registro_de_ponto: {  }
    end

    assert_redirected_to registro_de_ponto_path(assigns(:registro_de_ponto))
  end

  test "should show registro_de_ponto" do
    get :show, id: @registro_de_ponto
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @registro_de_ponto
    assert_response :success
  end

  test "should update registro_de_ponto" do
    put :update, id: @registro_de_ponto, registro_de_ponto: {  }
    assert_redirected_to registro_de_ponto_path(assigns(:registro_de_ponto))
  end

  test "should destroy registro_de_ponto" do
    assert_difference('RegistroDePonto.count', -1) do
      delete :destroy, id: @registro_de_ponto
    end

    assert_redirected_to registros_de_ponto_path
  end
end
