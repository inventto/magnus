#encoding: utf-8
require 'time'
class Pessoa < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :cpf, :telefones, :endereco, :codigo_de_acesso
  TIPOS = ['Aluno', 'Personal','Secretária', 'Zeladora']

  TIPOS.each_with_index do |tipo, i|
        scope tipo.downcase.to_sym, lambda { where(tipo_de_pessoa: i) }
  end

  scope :de_aniversario_no_mes, lambda { |mes| joins("JOIN matriculas ON matriculas.pessoa_id=pessoas.id").where("data_inicio <= ? and (data_fim >= ? or data_fim is null)", (Time.now).to_date, (Time.now).to_date).where("extract(month from data_nascimento) = #{mes}").group(:data_nascimento, :"pessoas.id").order("extract(day from data_nascimento)") }
  scope :com_matricula_valida, lambda { |data| joins(:matriculas).where("matriculas.data_fim >= ? or matriculas.data_fim is null", data) }

  before_save :chk_codigo_de_acesso

  has_many :telefones, :dependent => :destroy
  belongs_to :endereco
  has_many :matriculas, :dependent => :destroy
  has_many :presencas, :dependent => :destroy
  has_many :registros_de_ponto, :dependent => :destroy, :class_name => 'RegistroDePonto'

  mount_uploader :foto, FotoUploader

  validates_presence_of :nome, :data_nascimento
  regexp = /^[^0-9][a-zA-Z0-9_]+([\-.][a-zA-Z0-9_]+)*[@][a-zA-Z0-9_]+([.][a-zA-Z0-9_]+)*[.][a-zA-Z]{2,4}$/i
  validates_format_of :email, :with => regexp, :message => 'Inválido!', :unless => "email.blank?"
  validates :cpf, :uniqueness => true, :unless => "cpf.blank?", :cpf => true
  validates :codigo_de_acesso, :uniqueness => true

  SEX = %w(M F)

  def eh_professor?
    tipo_de_pessoa == 1
  end

  def primeiro_nome
    nome.gsub(/ .*$/, "")
  end

  def segundo_nome
    nome.gsub(/^[^ ]* /, "")
  end

  def get_presenca
    matricula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, @data_atual.wday).matricula_ativa
    horario_na_matricula = 0
    if not matricula.blank?
      horario_na_matricula = txt_to_seg(matricula[0].horario)
    end

    p = Presenca.where(:pessoa_id => self.id).where(:data => @data_atual)

    horario_na_realocacao = 0
    if not p.blank?
      p.each do |presenca|
        p = presenca

        next if not hora_esta_contida_em_horario?(@hora_atual, presenca.horario)
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

    hora_atual_in_sec = txt_to_seg(@hora_atual)

    dif_hora_matricula = nil
    dif_hora_realocacao = nil

    dif_hora_matricula = hora_atual_in_sec - horario_na_matricula if horario_na_matricula > 0
    dif_hora_realocacao = hora_atual_in_sec - horario_na_realocacao if horario_na_realocacao > 0

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

  def get_pontualidade
    horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, @hora_certa.wday).matriucla_ativa[0].horario
    horario_de_aula = txt_to_seg(horario_de_aula)
    hora_atual_in_sec = txt_to_seg(@hora_atual)
    ((horario_de_aula - hora_atual_in_sec) / 60).round # div por 60 para retornar em min. Retorna negativo se estiver atrasado e positivo adiantado
  rescue # caso o aluno não esteja em algum dia cadastrado nos horarios de aula
    nil
  end

  def get_pontualidade_da_realocacao
    if not @presenca.realocacao? and @presenca.data_de_realocacao.blank? # caso apenas esteja atrasado
      return get_pontualidade
    else # se não se for um adiantamento ou uma reposição
      horario_de_aula = txt_to_seg(@presenca.horario)
      hora_atual_in_sec = txt_to_seg(@hora_atual)
      return ((horario_de_aula - hora_atual_in_sec) / 60).round # div por 60 para retornar em min. Retorna negativo se estiver atrasado e positivo adiantado
    end
  end

  def get_hora_fora_de_horario
    seconds = txt_to_seg @hora_atual
    min_in_secs = seconds % 3600
    if min_in_secs > 1800 # se maior que 30 minutos
      return Time.at((seconds - min_in_secs) + 3600).gmtime.strftime("%H:%M")
    else
      return Time.at(seconds - min_in_secs).gmtime.strftime("%H:%M")
    end
  end

  def get_current_time time_millis
     if time_millis.nil?
      @hora_certa = (Time.now)
      @hora_atual = @hora_certa.strftime("%H:%M")
      @data_atual = @hora_certa.to_date
    else
      data_hora = Time.at(time_millis.to_i / 1000)
      @hora_atual = data_hora.strftime("%H:%M")
      @data_atual = data_hora.to_date
    end
    if Rails.env.development?#--> variáveis para teste local
      @hora_certa = Time.now
      @hora_atual = @hora_certa.strftime("%H:%M")
      @data_atual = Date.today
    end
  end

  def registrar_presenca time_millis
    get_current_time time_millis
    @presenca = get_presenca
    if @presenca.nil?
      verifica_e_gera_presenca_realocada
    elsif not @presenca.presenca?
      if not @presenca.realocacao?
        if esta_fora_de_horario?
          #@presenca.fora_de_horario = true
          @presenca.realocacao = true
        end
      end
      @presenca.pontualidade = get_pontualidade_da_realocacao
      @presenca.presenca = true
      @presenca.save
    end
  end

  def verifica_e_gera_presenca_realocada
    presenca = Presenca.new(:pessoa_id => self.id, :data => @data_atual, :presenca => true)
    if passe_livre?
      presenca.horario = Time.now.strftime("%H:%M")
    elsif (fora_do_horario = esta_fora_de_horario?) || (dia_errado = esta_no_dia_errado?)
      #presenca.fora_de_horario = true
      presenca.realocacao = true
      hora_da_aula = get_hora_fora_de_horario # faz a aproximação do horário, se maior que 30min soma 1 hora se não pega a hora dos minutos
      presenca.horario = hora_da_aula
      presenca.pontualidade = ((txt_to_seg(hora_da_aula) - txt_to_seg(@hora_atual)) / 60).round
      if fora_do_horario # registrou a presença no mesmo dia mas no horário diferente do da aula
        if txt_to_seg(@horario_de_aula.horario) > txt_to_seg(hora_da_aula)  # adiantamento, pois registrou a presença antes do horário da aula
          # Cria a falta justificada para o horário da aula
          criar_falta_com_justificativa_de_adiantamento(@data_atual, hora_da_aula, @horario_de_aula.horario)
        else
          # Cria a justificativa para a aula que está sendo reposta no dia
          falta = Presenca.find_by_pessoa_id_and_data_and_presenca_and_horario(self.id, @data_atual, false, @horario_de_aula.horario)
          if not falta.nil?
            falta.tem_direito_a_reposicao = true
            falta.build_justificativa_de_falta(:descricao => "aula reposta às #{hora_da_aula}")
            falta.justificativa_de_falta.save
            falta.save
          end
        end
        presenca.data_de_realocacao = @data_atual # pois tanto no adiantamento como na reposição existirá a data realocada
      elsif dia_errado
        # verificar quantas aulas a repor ainda possui
        count_aulas_a_repor = get_count_aulas_a_repor

        if count_aulas_a_repor < 1 # se não há aulas a repor deve-se gerar adiantamento
          # pegar a data da próxima aula para adiantá-la
          data = get_data(@hora_certa)

          while not Presenca.where(:pessoa_id => self.id).where(:data => data).blank?
            data = get_data(data)
          end

          horario_da_aula_da_matricula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, data.wday).matricula_ativa

          criar_falta_com_justificativa_de_adiantamento(data, hora_da_aula, horario_da_aula_da_matricula.first.horario)

          presenca.data_de_realocacao = data
          # else não precisa fazer pois a reposição é apenas uma presença como realocação já que a falta teoricamente já é para estar lançada
        end
      end
    else
      presenca.horario = @horario_de_aula.horario
      presenca.pontualidade = get_pontualidade
    end
    presenca.save
  end

  def get_count_aulas_a_repor
    count_aulas_repostas = get_aulas_repostas

    faltas_com_direito_a_reposicao = get_faltas_com_direito_a_reposicao

    count_faltas_com_direito_a_reposicao = faltas_com_direito_a_reposicao.count

    count_faltas_com_direto_a_repos_permitidas = get_amout_allowed_fault

    count_faltas_de_realocacoes_com_direito_a_repos = get_faltas_de_realocacoes_com_direito_a_reposicao

    count_faltas_de_realocacoes_sem_direito_a_repos = get_faltas_de_realocacoes_sem_direito_a_reposicao

    a_repor = count_faltas_com_direito_a_reposicao - count_aulas_repostas
    a_repor -= get_amount_of_expired_classes(a_repor, count_faltas_com_direto_a_repos_permitidas)
    a_repor -= count_faltas_de_realocacoes_sem_direito_a_repos - count_faltas_de_realocacoes_com_direito_a_repos
  end

  def get_amount_of_expired_classes amount, amount_allowed_fault
    (amount > amount_allowed_fault) ? amount - amount_allowed_fault : 0
  end

  def get_faltas_de_realocacoes_com_direito_a_reposicao
    faltas = Presenca.where(:pessoa_id => self.id, :realocacao => true).where("coalesce(presenca, 'f') = 'f'")
    faltas = faltas.where(:tem_direito_a_reposicao => true).count
  end

  def get_faltas_de_realocacoes_sem_direito_a_reposicao
    faltas = Presenca.where(:pessoa_id => self.id, :realocacao => true)
    faltas = faltas.where("coalesce(presenca, 'f') = 'f'")
    faltas = faltas.where("coalesce(tem_direito_a_reposicao, 'f') = 'f'").count
  end

  def self.tipos_select
    return @@tipos if defined? @@tipo
    @@tipos = []
    TIPOS.each_with_index do|tipo,i|
      @@tipos << [tipo, i]
    end
    @@tipos
  end


  def get_amout_allowed_fault
    valid_enrollment = Matricula.order(:id).find_all_by_pessoa_id(self.id).last # pega a última cadastrada que sempre será a válida
    weekly_frequency = HorarioDeAula.find_all_by_matricula_id(valid_enrollment.id).count
    (weekly_frequency * 4) # máximo de faltas em um mês
  end

  def criar_falta_com_justificativa_de_adiantamento data_da_aula_realocada, hora_da_aula_registrada, horario_da_aula_da_matricula
    falta = Presenca.find_by_pessoa_id_and_data_and_presenca_and_horario(self.id, @data_atual, false, horario_da_aula_da_matricula)
    if falta.nil?
      falta = Presenca.create(:pessoa_id => self.id, :data => data_da_aula_realocada, :presenca => false, :horario => horario_da_aula_da_matricula, :tem_direito_a_reposicao => true)
      falta.build_justificativa_de_falta(:descricao => "adiantado para o dia #{@data_atual.strftime("%d/%m/%Y")} às #{hora_da_aula_registrada}")
    else
      falta.tem_direito_a_reposicao = true
      if not falta.justificativa_de_falta.nil?
        falta.justificativa_de_falta.descricao = "adiantado para o dia #{@data_atual.strftime("%d/%m/%Y")} às #{hora_da_aula_registrada}"
      else
        falta.build_justificativa_de_falta(:descricao => "adiantado para o dia #{@data_atual.strftime("%d/%m/%Y")} às #{hora_da_aula_registrada}")
      end
    end
    falta.justificativa_de_falta.save
    falta.save
  end

  def get_data data
    proximo_horario_de_aula = get_proximo_horario_de_aula(data)
    return nil if not proximo_horario_de_aula
    dia = proximo_horario_de_aula.dia_da_semana - data.wday
    data = (data + dia.day).to_date
    if dia <= 0
      data = data + 7.day
    end
    data
  end

  def get_proximo_horario_de_aula data
    horarios_de_aula = HorarioDeAula.joins(:matricula).where(:"matriculas.pessoa_id" => self.id).order(:dia_da_semana)

    return horarios_de_aula[0] if horarios_de_aula.count == 1 # caso tenha horario de aula em somente um dia da semana

    aula_de_hoje = horarios_de_aula.find_by_dia_da_semana(data.wday)

    if not aula_de_hoje.nil? and Presenca.where(:pessoa_id => self.id).where(:data => data.to_date).blank?
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
    faltas = Presenca.where(:pessoa_id => self.id).where("coalesce(presenca,'f') = 'f'")
    faltas.where(:tem_direito_a_reposicao => true)
  end

  def get_aulas_repostas
    sub_query = "SELECT p2.data FROM presencas as p2"
    sub_query << " JOIN justificativas_de_falta as j ON j.presenca_id=p2.id"
    sub_query << " WHERE p2.data=presencas.data_de_realocacao AND"
    sub_query << " p2.pessoa_id=presencas.pessoa_id AND p2.presenca = 'f' AND"
    sub_query << " j.descricao <> '' AND p2.tem_direito_a_reposicao = 't'"

    repostas = Presenca.where(:pessoa_id => self.id, :realocacao => true, :presenca => true)
    repostas = repostas.where("(data_de_realocacao IN (#{sub_query}) OR data_de_realocacao is null)").count
    repostas
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
    (hora >= (horario - 1740)) && (hora <= (horario + 3600)) # 1740s = 29 min
  rescue
    nil
  end

  def passe_livre?
    matriculas.where("data_fim is null").each do |matricula|
      return true if matricula.horario_de_aula.empty?
    end
    return false
  end
  def esta_fora_de_horario?
    @hora_registrada = @hora_certa
    @horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(self.id, @hora_certa.wday).matricula_ativa[0]

    if not @presenca.nil? and @presenca.realocacao# se for reposição, adiantamento
      p "@presenca #{@presenca}"
      hora_da_aula = @presenca.horario
      @horario_de_aula = @presenca
    elsif not @horario_de_aula.nil?
      p "@hora_da_aula"
      hora_da_aula = @horario_de_aula.horario
    else
      p "@else"
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
      if aula and aula.justificativa_de_falta and aula.justificativa_de_falta.descricao and not aula.justificativa_de_falta.descricao.match(/adiantado/).nil? # se for um adiantamento
        aula = presencas[1] # presencas[1] para retornar o segundo registro já que o primeiro é um adiantamento
      end
    end
    if aula and not aula.data.nil? and not eh_feriado? aula.data
      aula
    end
  end

  def eh_feriado? data
    if is_a? String
      data = Time.strptime(data, "%d-%m-%Y") {|year| year + (year < 70 ? 2000 : 1900)}
    end
    feriado = Feriado.where(:dia => data.day).where(:mes => data.month).last
    feriado and (feriado.repeticao_anual or feriado.ano == data.year)
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
    Presenca.joins("LEFT JOIN justificativas_de_falta AS jus ON jus.presenca_id = presencas.id").where(:pessoa_id => self.id).where("data < ?", @hora_certa.to_date).order("data DESC").order("horario DESC")
  end

  def txt_to_seg hora
    Time.strptime(hora, "%H:%M").seconds_since_midnight
  rescue
    nil
  end

  def chegada_de_horario?
    (@ponto.nil?) ? true : false
  end

  def get_ponto
    RegistroDePonto.order(:id).find_all_by_pessoa_id_and_data(self.id, @data_atual).last
  end

  def registrar_ponto time_millis
    get_current_time time_millis
    @ponto = get_ponto
    if @ponto.nil?
      gravar_ponto
    else
      if @ponto.hora_de_saida.nil?
        @ponto.hora_de_saida = @hora_atual
        @ponto.save
      else
        @ponto = nil
        gravar_ponto
      end
    end
  end

  def gravar_ponto
      reg_ponto = RegistroDePonto.create(:pessoa_id => self.id, :data => @data_atual, :hora_de_chegada => @hora_atual)
  end

  def label
    nome
  end

  def matricula_valida
    matriculas.joins(:presencas).valida.first
  end

  def com_matricula_standby?
    matriculas.em_standby?(Time.now).exists?
  end

  def get_funcionario_horario_de_aula(hora, today)
    registros_ponto = RegistroDePonto.que_entrou_ate(hora, today)
    conditions = {}
    conditions[:id] = registros_ponto.collect(&:pessoa_id) if not registros_ponto.empty?
    Pessoa.where(conditions)
  end

  private

  def chk_codigo_de_acesso
    data = self.data_nascimento
    data = data.strftime("%d/%m/%Y")
    codigo = data[0..1] << data[3..4] << data[8..9]
    while(codigo_existe?(codigo))
      codigo << codigo[codigo.length - 1]
    end
    codigo = "9" << codigo if self.tipo_de_pessoa > 0
    self.codigo_de_acesso = codigo
  end

  def codigo_existe?(codigo)
    Pessoa.where('id <> ?', self.id).find_by_codigo_de_acesso(codigo)
  end
end
