class AgendaDoDiaController < ApplicationController
  def agenda
    @agenda_do_dia = HorarioDeAula.joins(:matricula).joins("INNER JOIN alunos ON matriculas.aluno_id=alunos.id").where(:"horarios_de_aula.dia_da_semana" => Time.now.wday).where("data_inicio <= current_date and data_fim >= current_date").order("cast(substr(horario,1,2) as int4),cast(substr(horario,4,2) as int4)")
  end
end
