# -*- encoding : utf-8 -*-
class TipoTelefone < ActiveRecord::Base
  attr_accessible :descricao

  has_one :telefone

  def label
    descricao
  end
end
