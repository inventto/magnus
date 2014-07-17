#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data

  belongs_to :presenca

  def label
    descricao
  end

end
