class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :presenca_id

  belongs_to :presenca
end
