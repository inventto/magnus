#encoding: utf-8
class JustificativasDeFaltaController < ApplicationController
  active_scaffold :justificativa_de_falta do |conf|
    conf.list.columns = [:descricao, :data]
    conf.columns = [:descricao, :data]
    conf.columns[:descricao].label = "Descrição"
    conf.columns[:data].label = "Data da justificativa"
  end
end
