require 'test_helper'

class RelatoriosControllerTest < ActionController::TestCase
  setup do
    @relatorio = relatorios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relatorios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relatorio" do
    assert_difference('Relatorio.count') do
      post :create, relatorio: { consulta: @relatorio.consulta, nome: @relatorio.nome, titulos: @relatorio.titulos }
    end

    assert_redirected_to relatorio_path(assigns(:relatorio))
  end

  test "should show relatorio" do
    get :show, id: @relatorio
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @relatorio
    assert_response :success
  end

  test "should update relatorio" do
    put :update, id: @relatorio, relatorio: { consulta: @relatorio.consulta, nome: @relatorio.nome, titulos: @relatorio.titulos }
    assert_redirected_to relatorio_path(assigns(:relatorio))
  end

  test "should destroy relatorio" do
    assert_difference('Relatorio.count', -1) do
      delete :destroy, id: @relatorio
    end

    assert_redirected_to relatorios_path
  end
end
