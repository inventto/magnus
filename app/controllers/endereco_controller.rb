class EnderecoController < ApplicationController
  active_scaffold :endereco do |conf|
    conf.columns = [:logradouro, :numero, :complemento, :bairro, :cidade]
  end
end
