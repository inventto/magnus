class Matricula < ActiveRecord::Base
  attr_accessible :aluno_id, :data_fim, :data_inicio, :data_matricula, :numero_de_aulas_previstas, :objetivo, :aluno, :horario_de_aula

  belongs_to :aluno
  has_many :horario_de_aula, :dependent => :destroy

  validates_presence_of :aluno

  def label
    aluno.nome
  end
end
