#encoding: utf-8
class Matricula < ActiveRecord::Base
  attr_accessible :pessoa_id, :data_fim, :data_inicio, :data_matricula, :numero_de_aulas_previstas, :objetivo, :pessoa, :horario_de_aula, :vip, :motivo_da_interrupcao, :inativo_ate, :inativo_desde

  attr_accessor :falta_em_percentual

  belongs_to :pessoa
  before_save :validar_numero_de_aulas_previstas
  has_many :horario_de_aula, :dependent => :destroy
  has_many :presencas, :through => :pessoa, :conditions => "presencas.created_at >= matriculas.created_at"
  has_many :interesse_no_horario, :dependent => :destroy

  validates_presence_of :pessoa
  #validates_presence_of :horario_de_aula
  validates_presence_of :data_inicio
  validates_numericality_of :numero_de_aulas_previstas, :unless => "numero_de_aulas_previstas.blank?"
  validate :data_final
  validate :validar_matricula, :on => :create
  validate :validar_data_inativa
  scope :clientes_que_ganhamos, where("data_inicio <= ?", Time.now).group_by{|data| [data.data_inicio.month, data.data_inicio.year]}
  scope :com_nome_parecido, ->(id) { where(pessoa_id: id) }
  scope :valida, where("(matriculas.data_fim > ? or matriculas.data_fim is null)", Time.now)
  scope :em_standby?, lambda {|na_data| where("data_fim is null and ? between inativo_desde and inativo_ate", na_data)}
  scope :faltas_por_semana_desde, lambda {|desde, pessoa_id=nil|
    fields = "presencas.pessoa_id, date_trunc('week',presencas.data) as semana, matriculas.numero_de_aulas_previstas"
      onde = valida
      if not pessoa_id.nil?
        onde = onde.com_nome_parecido(pessoa_id)
      end
     sql =
       onde.
        joins(:pessoa).joins("left join presencas on presencas.pessoa_id = pessoas.id").
          select("#{fields}, sum(case when not presencas.presenca and not presencas.realocacao then 1 else 0 end) as faltas_por_semana,
                 sum(case when presencas.realocacao and presencas.presenca then 1 else 0 end) as realocacoes_feitas").
            where("presencas.data >  ?", desde).
              group(fields.gsub(/ as [^,]*/,"")).
                order("presencas.pessoa_id asc, faltas_por_semana desc")

  }
  def self.com_mais_faltas(desde, pessoa_id=nil)
    query = "select sum(a.faltas_por_semana) / sum(coalesce(a.numero_de_aulas_previstas + 0.00001,1)) * 100 as percentual_faltas,
                    sum(a.faltas_por_semana - a.realocacoes_feitas) / sum(coalesce(a.numero_de_aulas_previstas + 0.00001,1)) * 100 as restante,  "+
       " a.pessoa_id from (#{Matricula.faltas_por_semana_desde(desde, pessoa_id).to_sql}) as a group by a.pessoa_id order by percentual_faltas desc"

     raw = ActiveRecord::Base.connection.exec_query(query)
     raw.inject({}) do |h,result|
       pessoa = Pessoa.find(result["pessoa_id"])
       percent = result["percentual_faltas"].to_f.round(2)
       restante = result["restante"].to_f.round(2)
       if percent > 0
         h[pessoa] = [percent, restante]
       else
         puts "Pessoa##{pessoa.id} está com #{percent}% de faltas. (analisar) "
       end
       h
     end
  end

  def data_final
    errors.add(:data_fim, "não pode ser menor que Data Inicial!") if data_fim and data_inicio and data_fim < data_inicio
  end

  def validar_matricula
    if not Matricula.where("data_fim is null and pessoa_id=?", pessoa_id).blank?
      self.errors.add(:pessoa, "já possui matrícula ativa.")
    end
  end

  def validar_data_inativa
    if (not self.inativo_desde and self.inativo_ate) or (not self.inativo_ate and self.inativo_desde )
      self.errors.add(:inativo_desde," e #{:inativo_ate} Ambos os campos inativos devem estar preenchidos.")
    end
    if self.inativo_desde and self.inativo_ate and (self.inativo_desde > self.inativo_ate)
      errors.add(:inativo_desde, "não pode ser maior que Data Inativo até!")
    end
  end

  def label
    pessoa.nome
  end

  def hora_da_aula dia_da_semana
    HorarioDeAula.find_all_by_dia_da_semana_and_matricula_id(dia_da_semana, id).collect{|h| h.horario }.join "/"
  end

  def percentual_de_faltas
   faltas = Presenca.count(:conditions =>["pessoa_id = ? and data between ? and ? and presenca = false", pessoa_id, data_inicio, data_fim])
   presencas = Presenca.count(:conditions =>["pessoa_id = ? and data between ? and ?", pessoa_id, data_inicio, data_fim])
   if presencas > 0
     return faltas / presencas
   else
     return 0
   end
  end

  def standby
    inativo_desde and inativo_ate and inativo_desde < inativo_ate
  end

  private
  def validar_numero_de_aulas_previstas
     if self.numero_de_aulas_previstas.nil?
      self.numero_de_aulas_previstas = self.horario_de_aula.size
     end
  end

end
