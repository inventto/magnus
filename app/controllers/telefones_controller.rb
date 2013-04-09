#coding: utf-8
class TelefonesController < ApplicationController
  active_scaffold :telefone do |conf|
    conf.columns = [:ddd, :numero, :descricao, :ramal, :tipo_telefone]
    conf.columns[:ddd].label = "DDD"
    conf.columns[:numero].label = "Número"
    conf.columns[:descricao].label = "Descrição"
  end
end
