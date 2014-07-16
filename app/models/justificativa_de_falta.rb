#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data

  belongs_to :presenca

  before_validation :tem_direito_a_reposicao

  def label
    descricao
  end

  private
  def tem_direito_a_reposicao
    matricula_id = Matricula.where(pessoa_id: presenca.pessoa.id).first
    maximo_reposicoes = HorarioDeAula.where(matricula_id: matricula_id.id).count * 4
    faltas_com_direito_reposicao = Presenca.where(:tem_direito_a_reposicao => true, presenca: false).count
    aulas_repostas =  Presenca.where(presenca: true, realcoacao: true)
    faltas_com_direito_reposicao -= aulas_repostas
    if descricao and maximo_reposicoes > faltas_com_direito_reposicao
      self.presenca.tem_direito_a_reposicao = true
    else
      self.presenca.tem_direito_a_reposicao = false
    end
  end
end
