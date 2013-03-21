class TelefoneController < ApplicationController
  active_scaffold :telefone do |conf|
    conf.columns = [:ddd, :numero, :descricao, :ramal, :tipo_telefone]
  end
end
