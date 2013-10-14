#coding: utf-8
class EnderecosController < ApplicationController
  active_scaffold :endereco do |conf|
    conf.columns = [:cep, :cidade, :logradouro, :numero, :complemento, :bairro ]
    conf.columns[:numero].label = "Número"
  end
end
