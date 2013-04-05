class AlunosController < ApplicationController
  active_scaffold :aluno do |conf|
    conf.columns = [:foto, :nome, :cpf, :email, :data_nascimento, :foto, :endereco, :telefones]
    conf.columns[:data_nascimento].options[:format] = :default
    conf.columns[:sexo].form_ui = :select
    conf.columns[:sexo].options = {:options => Aluno::SEX.map(&:to_sym)}
  end
end
