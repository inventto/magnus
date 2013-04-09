#coding: utf-8
class JustificativasDeFaltaController < ApplicationController
  active_scaffold :justificativa_de_falta do |conf|
    conf.columns[:descricao].label = "Descrição"
  end
end
