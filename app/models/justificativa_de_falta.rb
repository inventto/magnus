#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data

  belongs_to :presenca

  #before_save :tem_direito_a_reposicao

  def label
    descricao
  end

  private
  def tem_direito_a_reposicao
    matricula = Matricula.where(pessoa_id: presenca.pessoa.id).valida.first

    maximo_reposicoes = HorarioDeAula.where(matricula_id: matricula.id).count * 4
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> maximo #{maximo_reposicoes}"
    faltas_com_direito_reposicao = Presenca.where(tem_direito_a_reposicao: true, presenca: false, pessoa_id: matricula.pessoa_id).where("data >= ?", matricula.data_inicio)
    count_faltas_com_direito_reposicao = faltas_com_direito_reposicao.count
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> faltas deireito a reposição #{faltas_com_direito_reposicao}"
    aulas_repostas =  Presenca.where(presenca: true, realocacao: true, pessoa_id: matricula.pessoa_id).where("data >= ?", matricula.data_inicio).count
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> aulas repostas #{aulas_repostas}"
    faltas_com_direito_reposicao -= aulas_repostas
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> faltas com direito a reposição #{faltas_com_direito_reposicao}"
    if maximo_reposicoes > faltas_com_direito_reposicao

    else

    end
  end
end
