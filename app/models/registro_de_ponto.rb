# -*- encoding : utf-8 -*-
class RegistroDePonto < ActiveRecord::Base
  attr_accessible :data, :hora_de_chegada, :hora_de_saida, :pessoa, :pessoa_id

  belongs_to :pessoa

  validates_presence_of :pessoa, :data, :hora_de_chegada
  scope :entre, lambda {|a,b| where(data: a..b) }
  def label
    "Registro de Ponto para " << self.pessoa.nome
  end
end
