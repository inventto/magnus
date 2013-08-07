#coding: utf-8
class RegistrosDePontoController < ApplicationController
  active_scaffold :registro_de_ponto do |conf|
    conf.label = "Registros de Ponto"
    conf.columns[:hora_de_saida].label = "Hora de saída"
    conf.columns[:pessoa].form_ui = :select
    conf.columns = [:pessoa, :data, :hora_de_chegada, :hora_de_saida]
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:pessoa, :data, :hora_de_chegada, :hora_de_saida]
    list.sorting = [{:data => 'DESC'}, {:hora_de_chegada => 'DESC'}]
  end
end
