class AgendaDoDiaController < ApplicationController

  def agenda
    @agenda_do_dia = HorarioDeAula.joins(:matricula).where(:"horarios_de_aula.dia_da_semana" => Time.now.wday).where("data_inicio <= current_date and data_fim >= current_date ").order("cast(horario as int4)")
  end
end
