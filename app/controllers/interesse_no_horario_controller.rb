#encoding: utf-8
class InteresseNoHorarioController < ApplicationController
  active_scaffold :interesse_no_horario do |conf|
    conf.columns = [:descricao, :dia_da_semana, :horario]
    conf.columns[:ativo].label = "Ativo"
    conf.columns[:descricao].label = "Descrição"
    conf.columns[:horario].label = "Horário"
    conf.columns[:dia_da_semana].label = "Dia da Semana"
    conf.columns[:dia_da_semana].form_ui = :select
    conf.columns[:dia_da_semana].options = {:options => InteresseNoHorario::DIAS}
  end

  def index
       @interessados_nos_horarios = InteresseNoHorario.joins(:matricula).
       order(:dia_da_semana).where("coalesce(matriculas.data_matricula,matriculas.data_inicio) <= current_date and (matriculas.data_fim > current_date or matriculas.data_fim is null)").group_by{|h| h.dia_da_semana}
       @interessados_nos_horarios.each do |k, v|
         @interessados_nos_horarios[k] = v.group_by{|h| h.horario}
       end
  end

end
