class Endereco < ActiveRecord::Base
  attr_accessible :bairro_id, :cidade_id, :complemento, :logradouro_id, :numero
  has_one :aluno
  belongs_to :logradouro
  belongs_to :bairro
  belongs_to :cidade
end
