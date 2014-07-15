#encoding: utf-8
class JustificativasDeFaltaController < ApplicationController
  active_scaffold :justificativa_de_falta do |conf|
    conf.columns = [:data, :descricao]
    conf.columns[:descricao].label = "Descrição"
    conf.columns[:data].label = "Data"
  end
end
