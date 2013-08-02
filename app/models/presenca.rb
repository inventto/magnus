#coding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :aluno_id, :data, :horario, :justificativa_de_falta, :presenca, :realocacao, :pontualidade, :tem_direito_a_reposicao, :data_de_realocacao, :aula_extra

  before_create :gerar_realocacao

  belongs_to :aluno
  has_one :justificativa_de_falta, :dependent => :destroy

  validates_presence_of :aluno
  validates_presence_of :data
  validates_presence_of :horario

  validates_each :data_de_realocacao do |model, attr, value|
    if not value.blank?
      if HorarioDeAula.do_aluno_pelo_dia_da_semana(model.aluno_id, value.wday).blank?
        model.errors.add(attr, ": Aluno não possui horário de aula na(o) #{Date::DAYNAMES[value.wday].humanize}")
      end
    end
  end

  QUANTIDADES_DE_REGISTROS = %w(10 20 30 40 50 60 70 80 90 100)

  def quantidade_de_registros
  end

  def label
    "presença de " << aluno.nome
  end

  private
    def gerar_realocacao
      if not self.data_de_realocacao.blank?
        p = Presenca.order("id DESC").find_by_data_and_aluno_id(self.data_de_realocacao, self.aluno_id) #em ordem descrescente pois caso haja mais de uma realocação para esse dia
        if p.nil?
          if self.data == self.data_de_realocacao
            criar_adiantamento
          elsif self.data < self.data_de_realocacao # adiantamento
            criar_adiantamento
          end
          self.realocacao = true
        end
      end
    end

    def criar_adiantamento
      horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.aluno_id, self.data_de_realocacao.wday) # como é um adiantamento preciso saber qual o horário de aula do dia da realocação

      # Cria falta justificada
      falta = Presenca.create(:aluno_id => self.aluno_id, :data => self.data_de_realocacao, :presenca => false, :horario => horario_de_aula[0].horario)
      JustificativaDeFalta.create(:presenca_id => falta.id, :descricao => "adiantado para o dia #{Date.parse(self.data.to_s).strftime("%d/%m/%Y")} às #{self.horario}")
    end
end
