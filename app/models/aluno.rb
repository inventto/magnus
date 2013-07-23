#coding: utf-8
class Aluno < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :cpf, :telefones, :endereco, :codigo_de_acesso

  scope :de_aniversario_no_mes, lambda { |mes| joins("JOIN matriculas ON matriculas.aluno_id=alunos.id").where("data_inicio <= ? and (data_fim >= ? or data_fim is null)", (Time.now + Time.zone.utc_offset).to_date, (Time.now + Time.zone.utc_offset).to_date).where("extract(month from data_nascimento) = #{mes}").group(:data_nascimento, :"alunos.id").order("extract(day from data_nascimento)") }

  before_save :chk_codigo_de_acesso
  after_save :send_data_to_sisagil

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

  def primeiro_nome
    nome.gsub(/ .*$/, "")
  end

  def segundo_nome
    nome.gsub(/^[^ ]* /, "")
  end

  def send_data_to_sisagil
    send_data(get_json_aluno)
  end

  def send_data json_aluno
    require 'net/http'
    require 'uri'

    user = 'invent.to.magnus'
    password = '123'

    url = 'http://sisagil.com/service'
    url = URI.parse(url)

    request = Net::HTTP::Post.new(url.path)
    request.basic_auth user, password
    request.set_form_data({'action'=>'save', 'entity'=>'pessoa', 'json' => json_aluno.to_json.to_s})

    response = Net::HTTP.new(url.host, url.port).start {|http| http.request(request) }
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      msg = response.body
      if msg["FAILURE"]
        logger.warn("=== .: Erro ao enviar dados ao Sisagil - Aluno ID #{self.id}:. ===")
        logger.warn(msg)
      else
        logger.info("=== .: Aluno ID #{self.id} Enviado ao Sisagil com Sucesso! :. ===")
      end
    else
      puts response.error!
    end
  end

  def get_json_aluno
    param_nome_municipio = {}
    if not self.endereco.nil? and not self.endereco.cidade.nil?
      if (nome = self.endereco.cidade.nome.chomp) == 'Francisco Beltrão'
        param_nome_municipio = {"codigoIbge" => 410840, "nome" => nome}
      else
        param_nome_municipio = {"nome" => nome}
      end
    else
      param_nome_municipio = {"nome" => ""}
    end

    json_aluno = {
      "codigoReferencial" => self.id.to_s,
      "nome" => self.nome.upcase,
      "nomeFantasia" => "",
      "cpfCnpj" => self.cpf.to_s.gsub(/[.-]/, ""),
      "tipo" => "F",
      "sexo" => self.sexo,
      "dataNascimento" => self.data_nascimento.strftime("%d/%m/%Y"),
      "endereco" => (self.endereco.nil?) ? "" : self.endereco.logradouro.upcase,
      "numero"=> (self.endereco.nil?) ? "" : self.endereco.numero,
      "municipio"=> param_nome_municipio,
      "estado"=> { "sigla" => (self.endereco.nil? or self.endereco.cidade.nil?) ? "" : self.endereco.cidade.estado.sigla },
      "cep" => (self.endereco.nil? or self.endereco.cep.nil?) ? "" : self.endereco.cep.gsub(/[.-]/,""),
      "email" => self.email.to_s,
      "fone" => begin Telefone.select("(lpad(ddd, 3, '0')||numero) as fone").order(:id).find_by_self_id(self.id)[:fone].gsub(/[\(\)\/-]/,"").gsub(/\s/,"") rescue "" end,
      "celular" => "",
      "fax" => "",
      "observacoes" => "",
      "bairro" => (self.endereco.nil? or self.endereco.bairro.nil?) ? "" : self.endereco.bairro.nome.upcase,
      "complemento" => (self.endereco.nil? or self.endereco.complemento.nil?) ? "" : self.endereco.complemento.upcase,
      "dataCadastro" => self.created_at.strftime("%d/%m/%Y"),
      "tipoCliente" => true,
      "tipoFornecedor" => false,
      "tipoFuncionario" => false,
      "rgIc" => "",
      "im" => "",
      "cnae" => "",
      "valorSalario" => 0.0,
      "codigoPais" => 1058,
      "nomeParaContato" => ""
    }
    json_aluno
  end

  def get_presenca data_atual, hora_atual
    matricula =  HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, data_atual.wday)
    horario_na_matricula = 0
    if not matricula.blank?
      horario_na_matricula = txt_to_seg(matricula[0].horario)
    end

    p = Presenca.where(:aluno_id => self.id).where(:data => data_atual)

    horario_na_realocacao = 0
    if not p.blank?
      p.each do |presenca|
        p = presenca

        next if not hora_esta_contida_em_horario?(hora_atual, presenca.horario)
        if presenca.realocacao
          horario_na_realocacao = presenca.horario
          if not horario_na_realocacao.blank?
            horario_na_realocacao = txt_to_seg(horario_na_realocacao)
          end
        else
          return presenca
        end
      end
    end

    hora_atual = txt_to_seg(hora_atual)

    dif_hora_matricula = nil
    dif_hora_realocacao = nil

    dif_hora_matricula = hora_atual - horario_na_matricula if horario_na_matricula > 0
    dif_hora_realocacao = hora_atual - horario_na_realocacao if horario_na_realocacao > 0

    dif_hora_matricula = dif_hora_matricula * -1 if not dif_hora_matricula.nil? and dif_hora_matricula < 0
    dif_hora_realocacao = dif_hora_realocacao * -1 if not dif_hora_realocacao.nil? and dif_hora_realocacao < 0

    if not p.blank? and not dif_hora_realocacao.nil?
      if (not dif_hora_matricula.nil? and dif_hora_realocacao < dif_hora_matricula) or dif_hora_matricula.nil?
        return p
      else
        return nil
      end
    else
      return nil
    end
  end

  def get_pontualidade hora_atual
    horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, @hora_certa.wday)[0].horario
    horario_de_aula = txt_to_seg(horario_de_aula)
    hora_atual = txt_to_seg(hora_atual)
    ((horario_de_aula - hora_atual) / 60).round # div por 60 para retornar em min. Retorna negativo se estiver atrasado e positivo adiantado
  rescue # caso o aluno não esteja em algum dia cadastrado nos horarios de aula
    nil
  end

  def get_pontualidade_da_realocacao hora_atual
    if not @presenca.realocacao? and @presenca.data_de_realocacao.blank? # caso apenas esteja atrasado
      return get_pontualidade(hora_atual)
    else # se não se for um adiantamento ou uma reposição
      horario_de_aula = txt_to_seg(@presenca.horario)
      hora_atual = txt_to_seg(hora_atual)
      return ((horario_de_aula - hora_atual) / 60).round # div por 60 para retornar em min. Retorna negativo se estiver atrasado e positivo adiantado
    end
  end

  def get_hora_fora_de_horario hora
    seconds = txt_to_seg hora
    min_in_secs = seconds % 3600
    if min_in_secs > 1800 # se maior que 30 minutos
      return Time.at((seconds - min_in_secs) + 3600).gmtime.strftime("%R:%S")[0..4]
    else
      return Time.at(seconds - min_in_secs).gmtime.strftime("%R:%S")[0..4]
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
    #@hora_certa = Time.now  #--> variáveis para teste local
    #hora_atual = @hora_certa.strftime("%H:%M")
    #data_atual = Date.today
    @presenca = get_presenca(data_atual, hora_atual)
    if @presenca.nil?
      verifica_e_gera_presenca_realocada(data_atual, hora_atual)
    elsif not @presenca.presenca?
      if not @presenca.realocacao?
        if esta_fora_de_horario?
          #@presenca.fora_de_horario = true
          @presenca.realocacao = true
        end
      end
      @presenca.pontualidade = get_pontualidade_da_realocacao(hora_atual)
      @presenca.presenca = true
      @presenca.save
    end
  end

  def verifica_e_gera_presenca_realocada data_atual, hora_atual
    presenca = Presenca.new(:aluno_id => self.id, :data => data_atual, :presenca => true)
    if (fora_do_horario = esta_fora_de_horario?) || (dia_errado = esta_no_dia_errado?)
      #presenca.fora_de_horario = true
      presenca.realocacao = true
      hora_da_aula = get_hora_fora_de_horario(hora_atual) # faz a aproximação do horário, se maior que 30min soma 1 hora se não pega a hora dos minutos
      presenca.horario = hora_da_aula
      presenca.pontualidade = ((txt_to_seg(hora_da_aula) - txt_to_seg(hora_atual)) / 60).round
      if fora_do_horario # registrou a presença no mesmo dia mas no horário diferente do da aula
        if txt_to_seg(@horario_de_aula.horario) > txt_to_seg(hora_da_aula)  # adiantamento, pois registrou a presença antes do horário da aula
          # Cria a falta justificada para o horário da aula
          criar_falta_com_justificativa_de_adiantamento(data_atual, data_atual, hora_da_aula, @horario_de_aula.horario)
        else
          # Cria a justificativa para a aula que está sendo reposta no dia
          falta = Presenca.find_by_aluno_id_and_data_and_presenca_and_horario(self.id, data_atual, false, @horario_de_aula.horario)
          if not falta.nil?
            falta.tem_direito_a_reposicao = true
            falta.save
            JustificativaDeFalta.create(:presenca_id => falta.id, :descricao => "aula reposta às #{hora_da_aula}")
          end
        end
        presenca.data_de_realocacao = data_atual # pois tanto no adiantamento como na reposição existirá a data realocada
      elsif dia_errado
        # verificar quantas aulas a repor ainda possui
        count_aulas_a_repor = get_count_aulas_a_repor

        if count_aulas_a_repor < 1 # se não há aulas a repor deve-se gerar adiantamento
          # pegar a data da próxima aula para adiantá-la
          data = get_data(@hora_certa)

          while not Presenca.where(:aluno_id => self.id).where(:data => data).blank?
            data = get_data(data)
          end

          horario_da_aula_da_matricula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, data.wday)

          criar_falta_com_justificativa_de_adiantamento(data, data_atual, hora_da_aula, horario_da_aula_da_matricula.first.horario)

          presenca.data_de_realocacao = data
          # else não precisa fazer pois a reposição é apenas uma presença como realocação já que a falta teoricamente já é para estar lançada
        end
      end
    else
      presenca.horario = @horario_de_aula.horario
      presenca.pontualidade = get_pontualidade(hora_atual)
    end
    presenca.save
  end

  def get_count_aulas_a_repor
    count_aulas_repostas = get_aulas_repostas
    faltas_com_direito_a_reposicao = get_faltas_com_direito_a_reposicao
    count_faltas_justificadas_com_direito_a_reposicao = faltas_com_direito_a_reposicao.count
    (count_faltas_justificadas_com_direito_a_reposicao - count_aulas_repostas)
  end

  def criar_falta_com_justificativa_de_adiantamento data_da_aula_realocada, data_do_dia, hora_da_aula_registrada, horario_da_aula_da_matricula
    falta = Presenca.create(:aluno_id => self.id, :data => data_da_aula_realocada, :presenca => false, :horario => horario_da_aula_da_matricula, :tem_direito_a_reposicao => true)
    JustificativaDeFalta.create(:presenca_id => falta.id, :descricao => "adiantado para o dia #{data_do_dia.strftime("%d/%m/%Y")} às #{hora_da_aula_registrada}")
  end

  def get_data data
    proximo_horario_de_aula = get_proximo_horario_de_aula(data)
    dia = proximo_horario_de_aula.dia_da_semana - data.wday
    data = (data + dia.day).to_date
    if dia < 0
      data = data + 7.day
    end
    data
  end

  def get_proximo_horario_de_aula data
    horarios_de_aula = HorarioDeAula.joins(:matricula).where(:"matriculas.aluno_id" => self.id).order(:dia_da_semana)

    return horarios_de_aula[0] if horarios_de_aula.count == 1 # caso tenha horario de aula em somente um dia da semana

    aula_de_hoje = horarios_de_aula.find_by_dia_da_semana(data.wday)

    if not aula_de_hoje.nil? and Presenca.where(:aluno_id => self.id).where(:data => data.to_date).blank?
      proximo_horario_de_aula = aula_de_hoje
    elsif horarios_de_aula.last == aula_de_hoje
      proximo_horario_de_aula = horarios_de_aula.first
    else
      proximo_horario_de_aula = horarios_de_aula.where("dia_da_semana > ?", data.wday).order(:dia_da_semana).limit(1)[0]
      if proximo_horario_de_aula.nil?
        proximo_horario_de_aula = horarios_de_aula.where("dia_da_semana < ?", data.wday).order(:dia_da_semana).limit(1)[0]
      end
    end

    proximo_horario_de_aula
  end

  def get_faltas_com_direito_a_reposicao
    faltas = Presenca.where(:aluno_id => self.id).where("data > ?", 2.month.ago)
    faltas.where(:presenca => false, :tem_direito_a_reposicao => true)
  end

  def get_aulas_repostas
    sub_query = "SELECT p2.data FROM presencas as p2 JOIN justificativas_de_falta as j ON j.presenca_id=p2.id WHERE p2.data=presencas.data_de_realocacao"
    sub_query << " AND p2.aluno_id=presencas.aluno_id AND p2.presenca = 'f' AND j.descricao <> '' AND p2.tem_direito_a_reposicao = 't'"
    count_aulas_repostas = Presenca.where(:aluno_id => self.id).where("data > ?", 2.month.ago).where(:realocacao => true, :presenca => true)
    count_aulas_repostas = count_aulas_repostas.where("(data_de_realocacao IN (#{sub_query}) OR data_de_realocacao is null)").count
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

  def aula_de_realocacao?
    if not @presenca.nil? and @presenca.realocacao?
      @hora_da_aula = Time.strptime(@presenca.horario, "%H:%M")
      return true
    end
  end

  def hora_esta_contida_em_horario?(hora, horario)
    hora = txt_to_seg(hora)
    horario = txt_to_seg(horario)

    (hora >= (horario - 900)) && (hora <= (horario + 3600))
  end

  def esta_fora_de_horario?
    @hora_registrada = @hora_certa
    @horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, @hora_certa.wday)[0]

    if not @presenca.nil? and @presenca.realocacao # se for reposição, adiantamento
      hora_da_aula = @presenca.horario
      @horario_de_aula = @presenca
    elsif not @horario_de_aula.nil?
      hora_da_aula = @horario_de_aula.horario
    else
      return false # se não for um adiantamento, nem uma reposição nem uma falta é uma presença fora de horário, logo não tem hora de aula
    end
    if not hora_esta_contida_em_horario?(@hora_registrada.strftime("%H:%M"), hora_da_aula)
      return true
    end
    @hora_da_aula = Time.strptime(hora_da_aula, "%H:%M")
    false
  end

  def esta_no_dia_errado?
    if @horario_de_aula.nil?
      if not aula_de_realocacao?
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
    min.round.to_s
  end

  def esta_atrasado?
    @hora_registrada > @hora_da_aula + 5.minutes
  end

  def primeira_aula?
    if @horario_de_aula.instance_of?(HorarioDeAula) # pois a váriavel pode ser uma instancia de Presenca, ver no método esta_fora_de_horario?
      @horario_de_aula.matricula.data_inicio == @hora_certa.to_date
    end
  end

  def get_falta_da_ultima_aula
    presencas = get_ultimas_aulas
    if not presencas.blank?
      aula = presencas.first
      if not aula.justificativa_de_falta.nil? and not aula.justificativa_de_falta.descricao.match(/adiantado/).nil? # se for um adiantamento
        aula = presencas[1] # presencas[1] para retornar o segundo registro já que o primeiro é um adiantamento
      end
    end
    aula
  end

  def faltou_aula_passada_e_justificou?
    aula = get_falta_da_ultima_aula
    if not aula.blank?
      return (not aula.presenca and not aula.justificativa_de_falta.nil? and aula.tem_direito_a_reposicao)
    end
  end

  def faltou_aula_passada_e_nao_justificou?
    aula = get_falta_da_ultima_aula
    if not aula.blank?
      return (not aula.presenca and aula.justificativa_de_falta.nil? and not aula.tem_direito_a_reposicao)
    end
  end

  def get_ultimas_aulas
    Presenca.joins("LEFT JOIN justificativas_de_falta AS jus ON jus.presenca_id = presencas.id").where(:aluno_id => self.id).where("data < ?", @hora_certa.to_date).order("data DESC").order("horario DESC")
  end

  def txt_to_seg hora
    Time.strptime(hora, "%H:%M").seconds_since_midnight
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
    data = self.data_nascimento
    data = data.strftime("%d/%m/%Y")
    codigo = data[0..1] << data[3..4] << data[8..9]
    while(codigo_existe?(codigo))
      codigo << codigo[codigo.length - 1]
    end
    self.codigo_de_acesso = codigo
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
