#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data

  belongs_to :presenca

  before_validation :verifica_se_tem_direito_a_reposicao
  validate :nao_permite_direito_a_reposicao_depois_de_3_horas

  def label
    descricao
  end

  private
  def nao_permite_direito_a_reposicao_depois_de_3_horas
    if not presenca.tem_direito_a_reposicao
          presenca.errors.add(presenca.horario, "Para ser um justificativa com direito a reposição, deve-se cadastrar 3 horas antes do horário de aula.")
    end
  end

  def verifica_se_tem_direito_a_reposicao
    hora_da_justificativa = Time.now.strftime("%H:%M")
    hora,minutos = presenca.horario.split(":")
    hora = hora.to_i - 3
    horario_limite = format("%.2d", hora) + ":#{minutos}"
    presenca.tem_direito_a_reposicao = (self.data and presenca.data == self.data and hora_da_justificativa <= horario_limite)
  end
end
