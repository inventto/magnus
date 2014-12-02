# -*- encoding : utf-8 -*-
class Cidade < ActiveRecord::Base
  attr_accessible :estado_id, :nome, :bairros, :estado

  belongs_to :estado
  has_many :bairros

  def label
    nome
  end
end
