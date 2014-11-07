#encoding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :pessoa_id, :pessoa, :data, :horario, :justificativa_de_falta, :data, :presenca, :realocacao, :pontualidade, :tem_direito_a_reposicao, :data_de_realocacao, :aula_extra

  belongs_to :pessoa
  has_one :justificativa_de_falta, :dependent => :destroy
  has_one :conciliamento_de, foreign_key: "de_id", class_name: Conciliamento, dependent: :destroy
  has_one :conciliamento_para, foreign_key: "para_id", class_name: Conciliamento

  scope :eh_falta, -> { where(presenca: false) }

  scope :com_direito_a_reposicao, -> { where(tem_direito_a_reposicao: true)}

  scope :eh_realocacao, -> { where(realocacao: true) }

  scope :eh_realocacao_na_data?, ->(data, horario, pessoa_id) { where("pessoa_id = ? and realocacao = true and horario = ? and data = ? and (tem_direito_a_reposicao = false or tem_direito_a_reposicao is null)", pessoa_id, horario, data)}

  scope :presencas_vinda, ->(pessoa_id) { where(pessoa_id: pessoa_id, aula_extra: false, presenca: true).where("(realocacao = false or realocacao is null)") }

  scope :presencas_extras, ->(pessoa_id) { where(pessoa_id: pessoa_id, aula_extra: true, presenca: true) }

  scope :faltas_sem_direito_a_reposicao, ->(pessoa_id) { where("pessoa_id = ? and presenca = false and (tem_direito_a_reposicao is null or tem_direito_a_reposicao = false)", pessoa_id)}

  scope :faltas_com_direito_a_reposicao, ->(pessoa_id) { where(pessoa_id: pessoa_id, tem_direito_a_reposicao: true, presenca: false) }

  scope :presencas_realocadas, ->(pessoa_id) { where(pessoa_id: pessoa_id, realocacao: true, presenca: true) }

  scope :presencas_erroneas, ->(pessoa_id) { where("pessoa_id = ? and ((presenca = true and tem_direito_a_reposicao = true) or (presenca = true and realocacao = true and tem_direito_a_reposicao = true))", pessoa_id)  }

  scope :presencas_expiradas, ->(pessoa_id) { where(pessoa_id: pessoa_id, expirada: true) }

  scope :presencas_expiradas_por_mes_e_ano, ->(pessoa_id, mes, ano) { where("pessoa_id = ? and expirada = true and Extract('Month' from data) = ? and Extract('Year'from data) = ?", pessoa_id, mes, ano)  }

  scope :pessoa_com_faltas_justificadas, ->(pessoa_id) { joins(:justificativa_de_falta).where(:pessoa_id => pessoa_id, :presenca => false, :tem_direito_a_reposicao => true).where("justificativas_de_falta.descricao is not null") }

  scope :com_conciliamentos_em_aberto, -> { joins(:conciliamento_de).where("para_id is null").order(:id)}

  scope :reposicao_ou_adiantamento_com_conciliamentos_em_aberto, -> { joins(:conciliamento_de).where("para_id is null and conciliamento_condition_type <> 'Expirada' and conciliamento_condition_type <> 'Abatimento'").order(:id) }

  scope :eh_aula_extra, -> { where(aula_extra: true).order(:id) }

  scope :eh_abatimento, -> { where("conciliamento_condition_type = 'Abatimento'")}

  scope :eh_adiantamento_na_data?, ->(data) { 
    joins(:justificativa_de_falta).
    where(presenca: false, data: data, tem_direito_a_reposicao: true).
    where("justificativas_de_falta.descricao ilike '%adiantado%'")
  }

  after_save :expira_reposicoes, :conciliamento_de_presencas

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
  def save_adiantamento
    adiantamento = Adiantamento.new
    adiantamento.de_id = self.id
    adiantamento.save
    self.conciliamento_de = adiantamento.conciliamento
    self.save
  end

  def save_reposicao
    reposicao = Reposicao.new
    reposicao.de_id = self.id
    reposicao.save
    self.conciliamento_de = reposicao.conciliamento
    self.save
  end

  def expira_reposicoes
    matricula = pessoa.matriculas.valida.first
    return unless matricula
    #limite de reposições
    count_maximo_reposicoes = matricula.count_maximo_reposicoes

    # todas as faltas do aluno com direito a reposição e com conciliamento
    presenca_com_conciliamento = pessoa.presencas.reposicao_ou_adiantamento_com_conciliamentos_em_aberto
    count_presenca_com_conciliamento = presenca_com_conciliamento.count

    presenca_com_conciliamento.order(:data)[-count_presenca_com_conciliamento ... -count_maximo_reposicoes].each  do |falta|
      falta.conciliamento_de.expirar!
    end
  end

  def save_abatimento
    abatimento = Abatimento.new
    abatimento.de_id = self.id
    abatimento.save
    self.conciliamento_de = abatimento.conciliamento
    self.save
  end

  def atualizar_abatimento
    abatimento_em_aberto = pessoa.presencas.com_conciliamentos_em_aberto.eh_abatimento.first
    if abatimento_em_aberto
      conciliamento_de_abatimento = abatimento_em_aberto.conciliamento_de
      if conciliamento_de_abatimento
        conciliamento_de_abatimento.update_attributes(para_id: self.id)
      end
    end
  end

  def conciliamento_de_presencas
    eh_adiantamento = !pessoa.presencas.eh_adiantamento_na_data?(self.data).blank?
    possui_abatimento_em_aberto = !pessoa.presencas.com_conciliamentos_em_aberto.eh_abatimento.blank?

    if self.tem_direito_a_reposicao and not self.conciliamento_de and not self.realocacao 
      if eh_adiantamento
        save_adiantamento
      elsif possui_abatimento_em_aberto
        atualizar_abatimento
      else
        save_reposicao
      end
    elsif self.realocacao and not self.conciliamento_para 
      atualizar_conciliamento_para_id
    elsif self.aula_extra and not self.conciliamento_de
      save_abatimento
    end
  end

  def atualizar_conciliamento_para_id
    presenca = pessoa.presencas.reposicao_ou_adiantamento_com_conciliamentos_em_aberto.first
    if presenca
      _conciliamento = presenca.conciliamento_de
      if _conciliamento
        _conciliamento.update_attributes(para_id: self.id)
      end
    else
      self.errors.add(:presenca, ": Aluno não possui mais direito a Realocação, pois não possui mais nenhuma falta com direito a reposição.")
    end
  end

end
