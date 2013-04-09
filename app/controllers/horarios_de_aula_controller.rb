#coding: utf-8
class HorariosDeAulaController < ApplicationController
  active_scaffold :horario_de_aula do |conf|
    conf.columns = [:dia_da_semana, :horario]
    conf.columns[:dia_da_semana].form_ui = :select
    conf.columns[:dia_da_semana].options = {:options => HorarioDeAula::DIAS}
    conf.columns[:horario].label = "Horário"
  end
end
