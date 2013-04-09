#coding: utf-8
class PresencasController < ApplicationController
  active_scaffold :presenca do |conf|
    conf.label = "Presenças"
    conf.columns[:presenca].label = "Presença"
    conf.columns[:horario].label = "Horário"
    conf.columns = [:aluno, :data, :horario, :presenca, :justificativa_de_falta]
    conf.columns[:aluno].form_ui = :select
  end
end
