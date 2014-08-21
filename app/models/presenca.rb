#encoding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :pessoa_id, :pessoa, :data, :horario, :justificativa_de_falta, :data, :presenca, :realocacao, :pontualidade, :tem_direito_a_reposicao, :data_de_realocacao, :aula_extra

  belongs_to :pessoa
  has_one :justificativa_de_falta, :dependent => :destroy

  after_save :expira_reposicoes

  regex_horario =/(^\d{2})+([:])(\d{2}$)/
  validates_format_of :horario, :with => regex_horario, :message => 'Inválido!'
  validates_presence_of :pessoa
  validates_presence_of :data
  validates_presence_of :horario

  validates_each :data_de_realocacao do |model, attr, value|
    if not value.blank?
      if HorarioDeAula.do_aluno_pelo_dia_da_semana(model.pessoa_id, value.wday).blank?
        model.errors.add(attr, ": Aluno não possui horário de aula na(o) #{Date::DAYNAMES[value.wday].humanize}")
      end
    end
  end

  QUANTIDADES_DE_REGISTROS = %w(10 20 30 40 50 60 70 80 90 100)

  def label
    "presença de " << pessoa.nome
  end

  private
  def expira_reposicoes
    return unless self.tem_direito_a_reposicao

    Presenca.set_faltas_expiradas(self.pessoa_id)
  end

  def self.set_faltas_expiradas pessoa_id
    matricula = Matricula.where(pessoa_id: pessoa_id).valida.first
    return unless matricula
    #limite de reposições
    count_maximo_reposicoes = HorarioDeAula.where(matricula_id: matricula.id).count * 4

    # todas as faltas do aluno com direito a reposição
    faltas_com_direito_reposicao = Presenca.where(tem_direito_a_reposicao: true, presenca: false, pessoa_id: pessoa_id).where("presencas.data >= ?",matricula.data_inicio)

    saldo_reposicoes = faltas_com_direito_reposicao.count

    aulas_repostas = Presenca.where(presenca: true, realocacao: true, pessoa_id: pessoa_id).where("presencas.data >= ?", matricula.data_inicio)
    count_aulas_repostas = aulas_repostas.count

    #Quantidade de faltas que tem direito a reposição
    saldo_reposicoes -= count_aulas_repostas

    # verifica se saldo e negativo
    if saldo_reposicoes > 0
      faltas_com_direito_reposicao.order(:data)[-saldo_reposicoes ... -count_maximo_reposicoes].each do |falta|
        falta.tem_direito_a_reposicao = false
        falta.expirada = true
        falta.save
      end
    end
  end
end
