#coding: utf-8
class PresencasController < ApplicationController
  active_scaffold :presenca do |conf|
    conf.label = "Presenças"
    conf.columns[:presenca].label = "Presença"
    conf.columns[:horario].label = "Horário"
    conf.columns[:reposicao].label = "Reposição"
    conf.columns[:fora_de_horario].label = "Fora de Horário"
    conf.columns = [:aluno, :data, :horario, :pontualidade, :presenca, :reposicao, :fora_de_horario, :justificativa_de_falta]
    conf.columns[:aluno].form_ui = :select
    conf.columns[:justificativa_de_falta].allow_add_existing = false
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:aluno, :data, :horario, :pontualidade, :presenca, :reposicao, :fora_de_horario]
    list.sorting = [{:data => 'DESC'}, {:horario => 'DESC'}]
  end
end
