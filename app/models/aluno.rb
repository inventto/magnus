#coding: utf-8
class Aluno < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :cpf, :telefones, :endereco, :codigo_de_acesso

  scope :de_aniversario_no_mes, lambda { |mes| where("extract(month from data_nascimento) = #{mes}").group(:data_nascimento, :id).order("extract(day from data_nascimento)") }

  before_save :chk_codigo_de_acesso

  has_many :telefones, :dependent => :destroy
  belongs_to :endereco
  has_one :matricula, :dependent => :destroy
  has_many :presencas, :dependent => :destroy
  mount_uploader :foto, FotoUploader

  validates_presence_of :nome, :data_nascimento
  validates_format_of :email, :with => /^([[^õüãáéíóúç]^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Inválido!', :unless => "email.blank?"
  validates :cpf, :uniqueness => true, :unless => "cpf.blank?"
  validates :codigo_de_acesso, :uniqueness => true

  validates_each :cpf do |model, attr, value|
    if not value.blank?
      model.errors.add(attr, "Inválido!") unless model.valido?(value)
    end
  end

  SEX = %w(M F)

  def chk_horarios?(hora_presenca, hora_atual)
    hora_presenca = Time.strptime(hora_presenca, "%H:%M").seconds_since_midnight
    hora_registrada = Time.strptime(hora_atual, "%H:%M").seconds_since_midnight

    (hora_registrada >= (hora_presenca - 900)) && (hora_registrada <= (hora_presenca + 3600))
  end

  def get_presenca data_atual, hora_atual
    matricula =  HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, data_atual.wday)
    horario_na_matricula = 0
    if not matricula.blank?
      horario = matricula[0].horario
      horario_na_matricula = horario[0..1].to_i * 3600 + horario[1..2].to_i * 60
    end

    p = Presenca.where(:aluno_id => self.id).where(:data => data_atual)
    horario_na_reposicao = 0
    if not p.blank?
      p.each do |presenca|
        p = presenca
        next if not chk_horarios?(presenca.horario, hora_atual)
        if presenca.reposicao
          horario_na_reposicao = presenca.horario
          if not horario_na_reposicao.blank?
            horario_na_reposicao = horario_na_reposicao[0..1].to_i * 3600 + horario_na_reposicao[1..2].to_i * 60
          end
        elsif presenca.presenca
          return presenca
        end
      end
    end

    hora_atual = Time.strptime(hora_atual, "%H:%M").seconds_since_midnight

    dif_hora_matricula = 0
    dif_hora_reposicao = 0

    dif_hora_matricula = hora_atual - horario_na_matricula if horario_na_matricula > 0
    dif_hora_reposicao = hora_atual - horario_na_reposicao if horario_na_reposicao > 0

    dif_hora_matricula = dif_hora_matricula * -1 if dif_hora_matricula < 0
    dif_hora_reposicao = dif_hora_reposicao * -1 if horario_na_reposicao < 0

    if not p.blank? and dif_hora_reposicao < dif_hora_matricula
      return p
    else
      return nil
    end
  end

  def registrar_presenca time_millis
    if time_millis.nil?
      @hora_certa = (Time.now + Time.zone.utc_offset)
      hora_atual = @hora_certa.strftime("%H:%M")
      data_atual = @hora_certa.to_date
    else
      data_hora = Time.at(time_millis.to_i / 1000) + Time.zone.utc_offset
      hora_atual = data_hora.strftime("%H:%M")
      data_atual = data_hora.to_date
    end
#    @hora_certa =Time.now  #--> variáveis para teste local
#    hora_atual = @hora_certa.strftime("%H:%M")
#    data_atual = Date.today
    @presenca = get_presenca(data_atual, hora_atual) #Presenca.where(:data => data_atual).find_by_aluno_id(self.id)
    if @presenca.nil?
      presenca = Presenca.new(:aluno_id => self.id, :data => data_atual, :horario => hora_atual, :presenca => true)
      if esta_fora_de_horario? || esta_no_dia_errado?
        presenca.fora_de_horario = true
      end
      presenca.save
    elsif not @presenca.presenca?
      if not @presenca.reposicao?
        @presenca.horario = hora_atual
      end
      @presenca.presenca = true
      @presenca.save
    end
  end

  def esta_de_aniversario_esse_mes?
    if (mes = self.data_nascimento)
      mes.month == Time.now.month
    end
  end

  def esta_de_aniversario_essa_semana?
    if self.data_nascimento
      dia = self.data_nascimento.day
      mes = self.data_nascimento.month
      data_nascimento = Time.mktime(self.data_nascimento.year, mes, dia)
      aniversario = Time.mktime(Time.now().year(), mes, dia)
      ((Time.now().beginning_of_week)..(Time.now().end_of_week)).cover?(aniversario)
    end
  end

  def aula_de_reposicao?
    if not @presenca.nil? and @presenca.reposicao?
      @hora_da_aula = Time.strptime(@presenca.horario, "%H:%M")
      return true
    end
  end

  def chk_horarios? hora_registrada, hora_da_aula
    hora_registrada = hora_registrada.seconds_since_midnight
    hora_da_aula = Time.strptime(hora_da_aula, "%H:%M").seconds_since_midnight
    (hora_registrada >= (hora_da_aula - 900)) && (hora_registrada <= (hora_da_aula + 3600))
  end

  def esta_fora_de_horario?
    @hora_registrada = @hora_certa
    @horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, @hora_certa.wday)[0]
    if not @horario_de_aula.nil?
      hora_da_aula = @horario_de_aula[:horario]
      if not chk_horarios?(@hora_registrada, hora_da_aula)
        return true
      end
      @hora_da_aula = Time.parse(hora_da_aula)
    end
    false
  end

  def esta_no_dia_errado?
    if @horario_de_aula.nil?
      if not aula_de_reposicao?
        return true
      end
    end
    false
  end

  def esta_adiantado?
    @hora_registrada < @hora_da_aula - 3.minutes
  end

  def minutos_atrasados
    dif = @hora_registrada - @hora_da_aula
    min = dif / 60
#    seg = dif % 60
#    if seg.round < 10
#      seg = "0" << seg.round.to_s
#    else
#      seg = seg.round.to_s
#    end
    min.round.to_s
  end

  def esta_atrasado?
    @hora_registrada > @hora_da_aula + 5.minutes
  end

  def primeira_aula?
    @horario_de_aula.matricula.data_inicio == @hora_certa.to_date
  end

  def faltou_aula_passada_sem_justificativa?
    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta AS jus ON jus.presenca_id = presencas.id").where(:aluno_id => self.id).where("data <> current_date")
    if not presenca.blank?
      return (not presenca.last.presenca and presenca.last.justificativa_de_falta.nil?)
    end
  end

  def label
    nome
  end

  def valido?(value)
    @numero = value
    @match = @numero =~ CPF_REGEX
    @numero_puro = $1
    @para_verificacao = $2
    @numero = (@match ? format_number! : nil)

    return false unless @match
    verifica_cpf
  end

  private

  def chk_codigo_de_acesso
    if self.codigo_de_acesso.blank?
      data = self.data_nascimento
      data = data.strftime("%d/%m/%Y")
      codigo = data[0..1] << data[3..4] << data[8..9]
      count = 4
      while(codigo_existe?(codigo))
        codigo[0] = count.to_s
        count += 1
      end
      self.codigo_de_acesso = codigo
    end
  end

  def codigo_existe?(codigo)
    Aluno.find_by_codigo_de_acesso(codigo)
  end

  DIVISOR = 11

  CPF_LENGTH = 11
  CPF_REGEX = /^(\d{3}\.?\d{3}\.?\d{3})-?(\d{2})$/
  CPF_ALGS_1 = [10, 9, 8, 7, 6, 5, 4, 3, 2]
  CPF_ALGS_2 = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

  def verifica_cpf
    limpo = @numero.gsub(/[\.\/-]/, "")
    return false if limpo.scan(/\d/).uniq.length == 1
    primeiro_verificador = primeiro_digito_verificador
    segundo_verificador = segundo_digito_verificador(primeiro_verificador)
    verif = primeiro_verificador + segundo_verificador
    verif == @para_verificacao
  end

  def multiplica_e_soma(algs, numero_str)
    multiplicados = []
    numero_str.scan(/\d{1}/).each_with_index { |e, i| multiplicados[i] = e.to_i * algs[i] }
    multiplicados.inject { |s,e| s + e }
  end

  def digito_verificador(resto)
    resto < 2 ? 0 : DIVISOR - resto
  end

  def primeiro_digito_verificador
    array = CPF_ALGS_1
    soma = multiplica_e_soma(array, @numero_puro)
    digito_verificador(soma%DIVISOR).to_s
  end

  def segundo_digito_verificador(primeiro_verificador)
    array = CPF_ALGS_2
    soma = multiplica_e_soma(array, @numero_puro + primeiro_verificador)
    digito_verificador(soma%DIVISOR).to_s
  end

  def format_number!
    @numero =~ /(\d{3})\.?(\d{3})\.?(\d{3})-?(\d{2})/
    @numero = "#{$1}.#{$2}.#{$3}-#{$4}"
  end
end
