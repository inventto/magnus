#coding: utf-8
class EnderecosController < ApplicationController
  active_scaffold :endereco do |conf|
    conf.columns = [:logradouro, :numero, :complemento, :bairro, :cidade, :cep]
    conf.columns[:numero].label = "Número"
  end
end
