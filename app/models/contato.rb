class Contato < ActiveRecord::Base
  belongs_to :pessoa
  attr_accessible :data_contato, :descricao
end
