class QuadroDeHorariosController < ApplicationController
  def index
    @horarios = HorarioDeAula.joins(:matricula).order(:dia_da_semana).where("matriculas.data_inicio <= current_date and (matriculas.data_fim >= current_date or matriculas.data_fim is null)").group_by{|h| h.dia_da_semana}
  end
end
