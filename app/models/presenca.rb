# -*- encoding : utf-8 -*-
#encoding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :pessoa_id, :pessoa, :data, :horario, :justificativa_de_falta, :data, :presenca, :realocacao, :pontualidade, :tem_direito_a_reposicao, :data_de_realocacao, :aula_extra

  belongs_to :pessoa
  has_one :justificativa_de_falta, :dependent => :destroy
  has_one :conciliamento_de, foreign_key: "de_id", class_name: Conciliamento, dependent: :destroy
  has_one :conciliamento_para, foreign_key: "para_id", class_name: Conciliamento

  scope :eh_falta, -> { where(presenca: false) }

  scope :eh_presenca, -> { where(presenca: true) } 

  scope :com_direito_a_reposicao, -> { where(tem_direito_a_reposicao: true) }

  scope :eh_realocacao, -> { where(realocacao: true) }

  scope :eh_realocacao_na_data?, ->(data, horario, pessoa_id) { where("pessoa_id = ? and realocacao = true and horario = ? and data = ? and (tem_direito_a_reposicao = false or tem_direito_a_reposicao is null)", pessoa_id, horario, data)}

  scope :presencas_vinda, -> { where(aula_extra: false, presenca: true).where("(realocacao = false or realocacao is null)") }

  scope :faltas_sem_direito_a_reposicao, -> { where("tem_direito_a_reposicao is null or tem_direito_a_reposicao = false")}

  scope :por_mes_e_ano, ->(mes, ano) { where("Extract('Month' from data) = ? and Extract('Year'from data) = ?", mes, ano)  }

  scope :com_justificativa, -> { joins(:justificativa_de_falta) }

  scope :com_conciliamentos_em_aberto, -> { joins(:conciliamento_de).where("para_id is null").order(:id)}

  scope :com_conciliamento, -> { joins(:conciliamento_de) }

  scope :com_conciliamento_para, -> { joins(:conciliamento_para) }

  scope :em_aberto, -> { where(conciliamentos: {para_id: nil}) }

  scope :e_fechado, -> { where("para_id is not null") }

  scope :reposicao_ou_adiantamento_com_conciliamentos_em_aberto, -> { joins(:conciliamento_de).
    where("para_id is null and conciliamento_condition_type <> 'Expirada' and conciliamento_condition_type <> 'Abatimento'").
    order(:id) 
  }

  scope :eh_aula_extra, -> { where(aula_extra: true).order(:id) }

  scope :eh_abatimento, -> { where("conciliamento_condition_type = 'Abatimento'")}

  scope :eh_reposicao, -> { where("conciliamento_condition_type = 'Reposicao'") }

  scope :eh_adiantamento, -> { where("conciliamento_condition_type = 'Adiantamento'") }

  scope :eh_expirada, -> { where("conciliamento_condition_type = 'Expirada'")}

  scope :da_matricula_atual, ->(data_inicio) { where("presencas.data >= ?", data_inicio)}
  
  scope :eh_adiantamento_na_data?, ->(data) { 
    joins(:justificativa_de_falta).
    where(presenca: false, presencas: {data: data}, tem_direito_a_reposicao: true).
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

  def presencas_da_matricula_valida
    data_inicio_das_presencas = pessoa.matriculas.valida.first.data_inicio
    pessoa.presencas.da_matricula_atual(data_inicio_das_presencas)
  end

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
    busca_e_atualiza_realocacoes
  end

  def busca_e_atualiza_realocacoes
    presencas_da_matricula_valida.eh_realocacao.each do |presenca|
      if not presenca.conciliamento_para and not presenca.tem_direito_a_reposicao?
        falta_de_reposicao = presencas_da_matricula_valida.com_conciliamento.eh_reposicao.em_aberto.first
        if falta_de_reposicao
          conciliamento_de_reposicao = falta_de_reposicao.conciliamento_de
          if conciliamento_de_reposicao
            conciliamento_de_reposicao.update_attributes(para_id: presenca.id)
          end
        end
      end
    end
  end

  def expira_reposicoes
    matricula = pessoa.matriculas.valida.first
    return unless matricula
    #limite de reposições
    count_maximo_reposicoes = matricula.count_maximo_reposicoes

    # todas as faltas do aluno com direito a reposição e com conciliamento
    presenca_com_conciliamento = presencas_da_matricula_valida.reposicao_ou_adiantamento_com_conciliamentos_em_aberto

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
    abatimento_em_aberto = presencas_da_matricula_valida.com_conciliamentos_em_aberto.eh_abatimento.first
    if abatimento_em_aberto
      conciliamento_de_abatimento = abatimento_em_aberto.conciliamento_de
      if conciliamento_de_abatimento
        conciliamento_de_abatimento.update_attributes(para_id: self.id)
      end
    end
  end

  def eh_adiantamento?
    !presencas_da_matricula_valida.eh_adiantamento_na_data?(self.data).blank?
  end

  def possui_abatimento_em_aberto?
    !presencas_da_matricula_valida.com_conciliamentos_em_aberto.eh_abatimento.blank?
  end

  def conciliamento_de_presencas
    matricula = pessoa.matriculas.valida.first
    return unless matricula

    if self.tem_direito_a_reposicao?  and not self.conciliamento_de and not self.conciliamento_para and not self.realocacao? and not self.presenca? 
      if eh_adiantamento?
        save_adiantamento
      elsif possui_abatimento_em_aberto?
        atualizar_abatimento
      else
        save_reposicao
      end
    elsif self.realocacao? and not self.conciliamento_para and not self.tem_direito_a_reposicao?
      atualizar_conciliamento_para_id
    elsif self.aula_extra? and not self.conciliamento_de
      save_abatimento
    end
  end

  def atualizar_conciliamento_para_id
    falta_de_adiantamento = presencas_da_matricula_valida.com_conciliamento.eh_adiantamento.em_aberto.first
    falta_de_reposicao = presencas_da_matricula_valida.com_conciliamento.eh_reposicao.em_aberto.first

    if falta_de_adiantamento
      conciliamento_de_adiantamento = falta_de_adiantamento.conciliamento_de
      if conciliamento_de_adiantamento
        conciliamento_de_adiantamento.update_attributes(para_id: self.id)
      end
    elsif falta_de_reposicao
      conciliamento_de_reposicao = falta_de_reposicao.conciliamento_de
      if conciliamento_de_reposicao
        conciliamento_de_reposicao.update_attributes(para_id: self.id)
      end
    else
      self.errors.add(:presenca, ": Aluno não possui mais direito a Realocação, pois não possui mais nenhuma falta com direito a reposição.")
    end
  end

end
