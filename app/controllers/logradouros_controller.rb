class LogradourosController < ApplicationController
  active_scaffold :logradouro do |conf|
    conf.columns = [:nome, :cep, :bairro]
    conf.columns[:bairro].form_ui = :select
  end
end
