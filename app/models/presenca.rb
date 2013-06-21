#coding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :aluno_id, :data, :horario, :justificativa_de_falta, :presenca, :realocacao, :fora_de_horario, :pontualidade, :tem_direito_a_realocacao, :data_de_realocacao

  belongs_to :aluno
  has_one :justificativa_de_falta, :dependent => :destroy

  validates_presence_of :aluno
  validates_presence_of :data
  validates_presence_of :horario

  def label
    "presença de " << aluno.nome
  end
end
