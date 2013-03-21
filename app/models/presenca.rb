class Presenca < ActiveRecord::Base
  attr_accessible :aluno_id, :data, :horario, :presenca, :justificativa_de_falta
  belongs_to :aluno
  has_one :justificativa_de_falta
end
