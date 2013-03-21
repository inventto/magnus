require 'test_helper'

class AlunosControllerTest < ActionController::TestCase
  setup do
    @aluno = alunos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alunos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create aluno" do
    assert_difference('Aluno.count') do
      post :create, aluno: { data_nascimento: @aluno.data_nascimento, email: @aluno.email, endereco_id: @aluno.endereco_id, foto: @aluno.foto, nome: @aluno.nome, sexo: @aluno.sexo }
    end

    assert_redirected_to aluno_path(assigns(:aluno))
  end

  test "should show aluno" do
    get :show, id: @aluno
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @aluno
    assert_response :success
  end

  test "should update aluno" do
    put :update, id: @aluno, aluno: { data_nascimento: @aluno.data_nascimento, email: @aluno.email, endereco_id: @aluno.endereco_id, foto: @aluno.foto, nome: @aluno.nome, sexo: @aluno.sexo }
    assert_redirected_to aluno_path(assigns(:aluno))
  end

  test "should destroy aluno" do
    assert_difference('Aluno.count', -1) do
      delete :destroy, id: @aluno
    end

    assert_redirected_to alunos_path
  end
end
