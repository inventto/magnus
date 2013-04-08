#coding: utf-8
class LogradourosController < ApplicationController
  active_scaffold :logradouro do |conf|
    conf.columns[:cep].label = "CEP"
    conf.columns = [:nome, :cep, :bairro]
    conf.columns[:bairro].form_ui = :select
  end
end
