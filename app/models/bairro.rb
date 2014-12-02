# -*- encoding : utf-8 -*-
class Bairro < ActiveRecord::Base
  attr_accessible :cidade_id, :nome, :cidade

  belongs_to :cidade

  def label
    nome
  end
end
