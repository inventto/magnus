class PresencasController < ApplicationController
  active_scaffold :presenca do |conf|
    conf.columns = [:aluno, :data, :horario, :presenca, :justificativa_de_falta]
  end
end
