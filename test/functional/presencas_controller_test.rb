require 'test_helper'

class PresencasControllerTest < ActionController::TestCase
  setup do
    @presenca = presencas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:presencas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create presenca" do
    assert_difference('Presenca.count') do
      post :create, presenca: { aluno_id: @presenca.aluno_id, data: @presenca.data, horario: @presenca.horario, presenca: @presenca.presenca }
    end

    assert_redirected_to presenca_path(assigns(:presenca))
  end

  test "should show presenca" do
    get :show, id: @presenca
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @presenca
    assert_response :success
  end

  test "should update presenca" do
    put :update, id: @presenca, presenca: { aluno_id: @presenca.aluno_id, data: @presenca.data, horario: @presenca.horario, presenca: @presenca.presenca }
    assert_redirected_to presenca_path(assigns(:presenca))
  end

  test "should destroy presenca" do
    assert_difference('Presenca.count', -1) do
      delete :destroy, id: @presenca
    end

    assert_redirected_to presencas_path
  end
end
