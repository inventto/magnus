#encoding: utf-8
class JustificativasDeFaltaController < ApplicationController
  active_scaffold :justificativa_de_falta do |conf|
    conf.list.columns = [:descricao, :hora, :data]
    conf.columns = [:descricao, :hora, :data]
    conf.columns[:descricao].label = "Descrição"
    conf.columns[:data].label = "Data"
    conf.columns[:hora].label = "Hora"
  end
end
