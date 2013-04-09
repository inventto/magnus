#coding: utf-8
class Matricula < ActiveRecord::Base
  attr_accessible :aluno_id, :data_fim, :data_inicio, :data_matricula, :numero_de_aulas_previstas, :objetivo, :aluno, :horario_de_aula

  belongs_to :aluno
  has_many :horario_de_aula, :dependent => :destroy

  validates_presence_of :aluno
  validates_presence_of :horario_de_aula
  validates_numericality_of :numero_de_aulas_previstas
  validate :data_final

  def data_final
    errors.add(:data_fim, "não pode ser menor que Data Inicial!") if data_fim < data_inicio
  end

  def label
    aluno.nome
  end
end
