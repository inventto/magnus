#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data

  belongs_to :presenca

  before_validation :tem_direito_a_reposicao

  def label
    descricao
  end

  private
  def tem_direito_a_reposicao
    if descricao
      presenca.tem_direito_a_reposicao = true
    end
  end
end
