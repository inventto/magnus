#coding: utf-8
class Presenca < ActiveRecord::Base
  attr_accessible :aluno_id, :data, :horario, :justificativa_de_falta, :presenca, :realocacao, :fora_de_horario, :pontualidade, :tem_direito_a_reposicao, :data_de_realocacao

  before_create :gerar_realocacao

  belongs_to :aluno
  has_one :justificativa_de_falta, :dependent => :destroy

  validates_presence_of :aluno
  validates_presence_of :data
  validates_presence_of :horario

  validates_each :data_de_realocacao do |model, attr, value|
    if not value.blank?
      model.errors.add(attr, ": Aluno não possui horário de aula na(o) #{Date::DAYNAMES[value.wday].humanize}") if HorarioDeAula.do_aluno_pelo_dia_da_semana(model.aluno_id, value.wday).blank?
    end
  end

  def label
    "presença de " << aluno.nome
  end

  private
    def gerar_realocacao
      if not self.data_de_realocacao.blank?
        p = Presenca.order("id DESC").find_by_data_and_aluno_id(self.data_de_realocacao, self.aluno_id) #em ordem descrescente pois caso haja mais de uma realocação para esse dia

        if self.data == self.data_de_realocacao
          if p.nil? # não existe registro de presença, logo, é um adiantamento
            criar_adiantamento
          end
        elsif self.data < self.data_de_realocacao # adiantamento
          criar_adiantamento
        end
        self.realocacao = true
      end
    end

    def criar_adiantamento
      horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.aluno_id, self.data_de_realocacao.wday) # como é um adiantamento preciso saber qual o horário de aula do dia da realocação

      # Cria falta justificada
      falta = Presenca.create(:aluno_id => self.aluno_id, :data => self.data_de_realocacao, :presenca => false, :horario => horario_de_aula[0].horario)
      JustificativaDeFalta.create(:presenca_id => falta.id, :descricao => "adiantado para o dia #{Date.parse(self.data.to_s).strftime("%d/%m/%Y")} às #{self.horario}")
    end

    def get_in_seconds hour
      Time.strptime(hour, "%H:%M").seconds_since_midnight
    end
end
