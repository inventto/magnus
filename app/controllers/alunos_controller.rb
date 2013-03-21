class AlunosController < ApplicationController
  active_scaffold :aluno do |conf|
    conf.columns = [:nome, :email, :data_nascimento, :sexo, :foto, :endereco, :telefones]
  end
end
