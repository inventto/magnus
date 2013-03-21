class TipoTelefone < ActiveRecord::Base
  attr_accessible :descricao
  has_one :telefone
end
