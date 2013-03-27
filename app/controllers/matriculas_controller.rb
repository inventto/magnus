class MatriculasController < ApplicationController
  active_scaffold :matricula do |conf|
   conf.columns = [:aluno, :data_matricula, :data_inicio, :data_fim, :numero_de_aulas_previstas, :objetivo, :horario_de_aula]
  end
end
