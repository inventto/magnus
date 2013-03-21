class Bairro < ActiveRecord::Base
  attr_accessible :cidade_id, :nome, :cidade

  belongs_to :cidade
  has_many :logradouros

  def label
    nome
  end
end
