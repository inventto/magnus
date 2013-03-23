class AlunosController < ApplicationController
  active_scaffold :aluno do |conf|
    conf.columns = [:nome, :email, :data_nascimento, :foto, :sexo, :endereco, :telefones]
    conf.columns[:data_nascimento].options[:format] = :default
    conf.columns[:sexo].form_ui = :select
    conf.columns[:sexo].options = {:options => Aluno::SEX.map(&:to_sym)}
  end
end
