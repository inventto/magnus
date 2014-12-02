# -*- encoding : utf-8 -*-
class QuadroDeHorariosController < ApplicationController
  def index
    @horarios = HorarioDeAula.joins(:matricula).order(:dia_da_semana).where("coalesce(matriculas.data_matricula,matriculas.data_inicio) <= current_date and (matriculas.data_fim > current_date or matriculas.data_fim is null)").group_by{|h| h.dia_da_semana}
    @horarios.each do |k, v|
      @horarios[k] = v.group_by{|h| h.horario}
    end
  end
end
