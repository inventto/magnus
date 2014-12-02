# -*- encoding : utf-8 -*-
#coding: utf-8
class FeriadosController < ApplicationController
  active_scaffold :feriado do |conf|
    conf.columns = [:descricao, :feriado_fixo, :repeticao_anual, :dia, :mes, :ano]
    conf.columns[:descricao].label = "Descrição"
    conf.columns[:feriado_fixo].label = "Feriado Fixo"
    conf.columns[:repeticao_anual].label = "Repetição Anual"
    conf.columns[:mes].label = "Mês"
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
  end
end
