#coding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :aluno_id, :data, :horario, :justificativa_de_falta, :presenca

  belongs_to :aluno

  has_one :justificativa_de_falta, :dependent => :destroy

  def label
    "presença de " << aluno.nome
  end
end
