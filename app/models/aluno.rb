#coding: utf-8
class Aluno < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :cpf, :telefones, :endereco

  has_many :telefones, :dependent => :destroy
  belongs_to :endereco
  has_one :matricula, :dependent => :destroy
  has_many :presencas, :dependent => :destroy
  mount_uploader :foto, FotoUploader

  validates_presence_of :nome
  validates_format_of :email, :with => /^([[^õüãáéíóúç]^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Inválido!', :unless => "email.blank?"
  validates :cpf, :presence => true, :uniqueness => true
  validates_each :cpf do |model, attr, value|
    model.errors.add(attr, "Inválido!") unless model.valido?(value)
  end

  SEX = %w(M F)

  def registrar_presenca
    Presenca.create(:aluno_id => self.id, :data => Date.today, :horario => Time.now.strftime("%H:%M"), :presenca => true)
  end

  def esta_de_aniversario_essa_semana?
    dia = self.data_nascimento.day
    mes = self.data_nascimento.month
    data_nascimento = Time.mktime(self.data_nascimento.year, mes, dia)
    aniversario = Time.mktime(Time.now().year(), mes, dia)
    ((Time.now() - 4.day)..(Time.now() + 4.day)).cover?(aniversario)
  end

  def esta_adiantado?
    @horario = HorarioDeAula.joins(:matricula).where(:"matriculas.aluno_id" => self.id).where(:dia_da_semana => Date.today.wday)[0]
    @hora_da_aula = Time.parse(@horario[:horario])
    @hora_registrada = Time.now
    @hora_registrada < @hora_da_aula - 3.minutes
  end

  def quantos_min_adiantado
    dif = @hora_da_aula - @hora_registrada
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

  def aula_de_reposicao?

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
