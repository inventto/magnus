class PresencasController < ApplicationController
  active_scaffold :presenca do |conf|
    conf.columns = [:data, :horario, :presenca, :aluno, :justificativa_de_falta]
  end
end
