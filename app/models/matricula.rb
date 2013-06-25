#coding: utf-8
class Matricula < ActiveRecord::Base
  attr_accessible :aluno_id, :data_fim, :data_inicio, :data_matricula, :numero_de_aulas_previstas, :objetivo, :aluno, :horario_de_aula, :vip, :motivo_da_interrupcao

  belongs_to :aluno
  has_many :horario_de_aula, :dependent => :destroy

  validates_presence_of :aluno
  validates_presence_of :horario_de_aula
  validates_presence_of :data_inicio
  validates_numericality_of :numero_de_aulas_previstas, :unless => "numero_de_aulas_previstas.blank?"
  validate :data_final
  validate :validar_matricula, :on => :create

  def data_final
    errors.add(:data_fim, "não pode ser menor que Data Inicial!") if data_fim and data_inicio and data_fim < data_inicio
  end

  def validar_matricula
    if not Matricula.where("data_fim is null and aluno_id=?", aluno_id).blank?
      self.errors.add(:aluno, "já possui matrícula ativa.")
    end
  end

  def label
    aluno.nome
  end

  def hora_da_aula dia_da_semana
    HorarioDeAula.find_all_by_dia_da_semana_and_matricula_id(dia_da_semana, id).collect{|h| h.horario }.join "/"
  end

  def percentual_de_faltas
   faltas = Presenca.count(:conditions =>["aluno_id = ? and data between ? and ? and presenca = false", aluno_id, data_inicio, data_fim])
   presencas = Presenca.count(:conditions =>["aluno_id = ? and data between ? and ?", aluno_id, data_inicio, data_fim])
   if presencas > 0
     return faltas / presencas
   else
     return 0
   end
  end
end
