#coding: utf-8
class Aluno < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :cpf, :telefones, :endereco, :codigo_de_acesso

  has_many :telefones, :dependent => :destroy
  belongs_to :endereco
  has_one :matricula, :dependent => :destroy
  has_many :presencas, :dependent => :destroy
  mount_uploader :foto, FotoUploader

  validates_presence_of :nome
  validates_format_of :email, :with => /^([[^õüãáéíóúç]^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Inválido!', :unless => "email.blank?"
  validates :cpf, :uniqueness => true, :unless => "cpf.blank?"

  validates_each :cpf do |model, attr, value|
    if not value.blank?
      model.errors.add(attr, "Inválido!") unless model.valido?(value)
    end
  end

  SEX = %w(M F)

  def get_presenca data_atual, hora_atual
    matricula =  HorarioDeAula.joins(:matricula).where(:dia_da_semana => data_atual.wday).where(:"matriculas.aluno_id" => self.id)
    horario_na_matricula = 0
    if not matricula.blank?
      horario = matricula[0].horario
      horario_na_matricula = horario[0..1].to_i * 3600 + horario[1..2].to_i * 60
    end

    presenca = Presenca.where(:data => data_atual).find_by_aluno_id(self.id)
    horario_na_reposicao = 0
    if not presenca.blank?
      if presenca.reposicao
        horario_na_reposicao = presenca.horario
        if not horario_na_reposicao.blank?
          horario_na_reposicao = horario_na_reposicao[0..1].to_i * 3600 + horario_na_reposicao[1..2].to_i * 60
        end
      elsif presenca.presenca
        return presenca
      end
    end

    hora_atual = Time.strptime(hora_atual, "%H:%M").seconds_since_midnight

    dif_hora_matricula = 0
    dif_hora_reposicao = 0

    dif_hora_matricula = hora_atual - horario_na_matricula if horario_na_matricula > 0
    dif_hora_reposicao = hora_atual - horario_na_reposicao if horario_na_reposicao > 0

    dif_hora_matricula = dif_hora_matricula * -1 if dif_hora_matricula < 0
    dif_hora_reposicao = dif_hora_reposicao * -1 if horario_na_reposicao < 0

    if dif_hora_reposicao < dif_hora_matricula
      return presenca
    else
      return nil
    end
  end

  def registrar_presenca time_millis
    if time_millis.nil?
      hora_atual = (Time.now + Time.zone.utc_offset).strftime("%H:%M")
      data_atual = Date.today
    else
      data_hora = Time.at(time_millis.to_i / 1000) + Time.zone.utc_offset
      hora_atual = data_hora.strftime("%H:%M")
      data_atual = data_hora.to_date
    end
#    hora_atual = Time.now.strftime("%H:%M")
#    data_atual = Date.today
    @presenca = get_presenca(data_atual, hora_atual) #Presenca.where(:data => data_atual).find_by_aluno_id(self.id)
    if @presenca.nil?
      presenca = Presenca.new(:aluno_id => self.id, :data => data_atual, :horario => hora_atual, :presenca => true)
      if esta_fora_de_horario?
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
    if self.data_nascimento
      dia = self.data_nascimento.day
      mes = self.data_nascimento.month
      data_nascimento = Time.mktime(self.data_nascimento.year, mes, dia)
      aniversario = Time.mktime(Time.now().year(), mes, dia)
      ((Time.now() - 30.day)..(Time.now() + 30.day)).cover?(aniversario)
    end
  end

  def esta_de_aniversario_essa_semana?
    if self.data_nascimento
      dia = self.data_nascimento.day
      mes = self.data_nascimento.month
      data_nascimento = Time.mktime(self.data_nascimento.year, mes, dia)
      aniversario = Time.mktime(Time.now().year(), mes, dia)
      ((Time.now() - 4.day)..(Time.now() + 4.day)).cover?(aniversario)
    end
  end

  def aula_de_reposicao?
    if not @presenca.nil? and @presenca.reposicao?
      @hora_da_aula = Time.strptime(@presenca.horario, "%H:%M")
      return true
    end
  end

  def esta_fora_de_horario?
    @horario = HorarioDeAula.joins(:matricula).where(:"matriculas.aluno_id" => self.id).where(:dia_da_semana => Date.today.wday)[0]
    if @horario.nil?
      if not aula_de_reposicao?
        return true
      end
    end
    @hora_da_aula = Time.parse(@horario[:horario])
    @hora_registrada = Time.now + Time.zone.utc_offset
    false
  end

  def esta_adiantado?
    @hora_registrada < @hora_da_aula - 3.minutes
  end

  def minutos_atrasados
    dif = @hora_registrada - @hora_da_aula
    min = dif / 60
    seg = dif % 60
    if seg.round < 10
      seg = "0" << seg.round.to_s
    else
      seg = seg.round.to_s
    end
    min.round.to_s
  end

  def esta_atrasado?
    @hora_registrada > @hora_da_aula + 5.minutes
  end

  def primeira_aula?
    @horario.matricula.data_inicio == Date.today
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
