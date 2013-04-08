#coding: utf-8
class PresencasController < ApplicationController
  active_scaffold :presenca do |conf|
    conf.label = "Presenças"
    conf.columns[:presenca].label = "Presença"
    conf.columns = [:aluno, :data, :horario, :presenca, :justificativa_de_falta]
  end
end
