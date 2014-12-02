# -*- encoding : utf-8 -*-
#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data, :hora

  belongs_to :presenca

  def label
    descricao
  end

end
