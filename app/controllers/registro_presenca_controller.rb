#coding: utf-8
class RegistroPresencaController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def registrar
    begin
      if params[:codigo].blank?
        flash[:error] = "Código do Aluno Inválido ou Aluno sem matrícula!"
        redirect_to "/registro_presenca"
        return
      else
        @aluno = Pessoa.com_matricula_valida((Time.now).to_date).find_by_codigo_de_acesso(params[:codigo])
        if not @aluno
          raise ""
        end
      end
    rescue
      flash[:error] = "Erro interno. Código do Aluno Inválido ou Aluno sem matrícula!"
      redirect_to "/registro_presenca"
      return
    end

    if not @aluno.registrar_presenca(nil)
      flash[:error] = "Aluno já possui Presença Registrada!"
      redirect_to "/registro_presenca"
      return
    end
    saudacao_ao @aluno
    @mensagem_sonora = ""
    notice = []
    error = []

    @matricula_standby = Matricula.where("standby is true")

    if @aluno.passe_livre?
      puts "=================> PASSE LIVRE"
      flash[:notice] = "Presença registrada!"
      return
    end
    if @aluno.esta_fora_de_horario?
      @mensagem_sonora = "Você está fora do horário da matrícula!"
      flash[:error] = "Você está fora do horário da matrícula!"
      return
    end
    if @aluno.esta_no_dia_errado?
      @mensagem_sonora = "Hoje não é seu dia normal de aula!"
      flash[:error] = "Hoje não é seu dia normal de aula!"
      return
    end
    if @aluno.aula_de_realocacao?
      @mensagem_sonora = "Hoje é sua Aula de Reposição!"
      notice << "Hoje é sua Aula de Reposição!"
    end
    if @aluno.esta_de_aniversario_essa_semana?
      @mensagem_sonora << "Parabéns! Essa semana você está de aniversário!"
      notice << "Parabéns! Essa semana você está de aniversário!"
    elsif @aluno.esta_de_aniversario_esse_mes?
      @mensagem_sonora << "Parabéns! Esse mês você está de aniversário."
      notice << "Parabéns! Esse mês você está de aniversário."
    end
    if @aluno.esta_adiantado?
      @mensagem_sonora << "Aguarde um instante para começar seu treinamento em seu horário. Agradecemos!"
      error << "Aguarde um instante para começar seu treinamento em seu horário. Agradecemos!"
    elsif @aluno.esta_atrasado?
      @mensagem_sonora << ("Você está atrasado " << @aluno.minutos_atrasados << " minutos. Procure não se atrasar novamente!")
      error << ("Você está atrasado " << @aluno.minutos_atrasados << " minutos. Procure não se atrasar novamente!")
    else
      @mensagem_sonora << "Parabéns pela sua pontualidade!"
      notice << "Parabéns pela sua pontualidade!"
    end
    if @aluno.primeira_aula?
      @mensagem_sonora << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
      notice << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
    end
    if not matricula_standby
      if @aluno.faltou_aula_passada_e_nao_justificou?
        @mensagem_sonora << "Você faltou aula passada e não justificou."
        error << "Você faltou aula passada e não justificou."
      elsif @aluno.faltou_aula_passada_e_justificou?
        @mensagem_sonora << "Você faltou aula passada e justificou."
        notice << "Você faltou aula passada e justificou."
      end
    end

    if @matricula_standby
      @mensagem_sonora << "Matrícula em estado inativo."
      notice << "Matrícula em estado inativo."
    end

    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?
  end

  def get_periodo
    periodo = {:manha => false, :tarde => false, :noite => false}
    today = (Rails.env.production?) ? Time.now : Time.now
    if (hora = today.hour) < 12.hours
      periodo[:manha] = true
    elsif hora > 12.hours and hora < 18.hours
      periodo[:tarde] = true
    else
      periodo[:noite] = true
    end
    periodo
  end

  def saudacao_ao pessoa
    periodo = get_periodo
    saudacao = ""
    saudacao_sonora = ""
    if periodo[:manha]
      saudacao << "Bom Dia "
      saudacao_sonora = "bom_dia|"
    elsif periodo[:tarde]
      saudacao << "Boa Tarde "
      saudacao_sonora = "boa_tarde|"
    else
      saudacao << "Boa Noite "
      saudacao_sonora = "boa_noite|"
    end
    if @msg_sonora_for_employee
      @msg_sonora_for_employee << saudacao_sonora
    end
    saudacao << pessoa.nome
  end

  def despedida_ao pessoa
    periodo = get_periodo
    despedida = ""
    despedida_sonora = ""
    if periodo[:manha]
      despedida = "Tenha uma Boa Tarde"
      despedida_sonora = "tenha_boa_tarde|"
    else
      despedida = "Tenha uma Boa Noite"
      despedida_sonora = "tenha_boa_noite|"
    end
    if @msg_sonora_for_employee
      @msg_sonora_for_employee << despedida_sonora
    end
    despedida
  end

  def registrar_ponto_android
    begin
      employee = Pessoa.find_by_e_funcionario_and_codigo_de_acesso(true, params[:codigo])
      if not employee
        raise ""
      end
    rescue
      logger.warn("=== .: Código do Funcionário Inválido: #{params[:codigo]} às #{(Time.now)} :.")
      flash[:error] = "Código do Funcionário Inválido!"
      render :text => [flash[:error], "codigo_funcionario_invalido"].join("|") and return
    end

    @msg_sonora_for_employee = ""
    notice = []

    time_millis = (not params[:tim_millis]) ? nil : params[:time_millis]

    registros = RegistroDePonto.where("pessoa_id = #{employee.id}").order(:id)
    ultimo_ponto = registros.last
    if ultimo_ponto.hora_de_saida.nil?
      primeiro_ponto = registros.first
      if primeiro_ponto.hora_de_saida < ultimo_ponto.hora_de_chegada
        primeiro_ponto = registros.second
      end
      if primeiro_ponto
        ultimo_ponto.hora_de_saida = primeiro_ponto.hora_de_saida
      else
        ultimo_ponto.hora_de_saida = ultimo_ponto.hora_de_chegada
      end
      ultimo_ponto.save
    end

    if not employee.registrar_ponto(time_millis)
      flash[:error] = "" # verificar
      render :text => [flash[:error], "funcionario_possui_presenca"].join("|") and return
    end

    return if not time_millis.nil?

    if employee.esta_de_aniversario_essa_semana?
      @msg_sonora_for_employee << "parabens_semana|"
      notice << "Parabéns! Essa semana você está de aniversário!"
    elsif employee.esta_de_aniversario_esse_mes?
      @msg_sonora_for_employee << "parabens_mes|"
      notice << "Parabéns! Esse mês você está de aniversário!"
    end

    notice = notice.join("<br/><br/>").html_safe

    saudacao = (chegada = employee.chegada_de_hora?) ? saudacao_ao(employee) : despedida_ao(employee)

    chegada = (chegada) ? 1 : 0

    render :text => [saudacao, employee.nome, employee.foto, notice, "", chegada, @msg_sonora_for_employee].join(";") and return
  end

  def registro_android
    begin
      aluno = Pessoa.com_matricula_valida((Time.now).to_date).find_by_codigo_de_acesso(params[:codigo])
      if not aluno
        raise ""
      end
    rescue
      logger.warn("=== .: Código do Aluno Inválido/Sem Matrícula: #{params[:codigo]} às #{(Time.now)} :.")
      flash[:error] = "Código do Aluno Inválido ou Aluno sem matrícula!"
      render :text => [flash[:error], "codigo_invalido"].join("|") and return
    end

    time_millis = (not params[:tim_millis]) ? nil : params[:time_millis]
    if not aluno.registrar_presenca(time_millis)
      flash[:error] = "Aluno já possui Presença Registrada!"
      render :text => [flash[:error], "aluno_possui_presenca"].join("|") and return
    end
    return if not time_millis.nil? # caso venha o time_millis significa que nada será exibido ao usuário, logo não havendo necessidade de executar os códigos abaixo

    saudacao = saudacao_ao aluno
    mensagem_sonora = ""
    notice = []
    error = []
    chegada = 1

    if aluno.esta_fora_de_horario?
      mensagem_sonora = "fora_de_horario|"
      flash[:error] = "Você está fora do horário da matrícula!"
      render :text => [saudacao, aluno.nome, aluno.foto, flash[:notice], flash[:error], chegada, mensagem_sonora].join(";") and return
    end
    if aluno.esta_no_dia_errado?
      mensagem_sonora = "dia_errado|"
      flash[:error] = "Hoje não é seu dia normal de aula!"
      render :text => [saudacao, aluno.nome, aluno.foto, flash[:notice], flash[:error], chegada, mensagem_sonora].join(";") and return
    end
    if aluno.aula_de_realocacao?
      mensagem_sonora = "aula_de_reposicao|"
      notice << "Hoje é sua aula de reposição!"
    end
    if aluno.esta_de_aniversario_essa_semana?
      mensagem_sonora << "parabens_semana|"
      notice << "Parabéns! Essa semana você está de aniversário!"
    elsif aluno.esta_de_aniversario_esse_mes?
      mensagem_sonora << "parabens_mes|"
      notice << "Parabéns! Esse mês você está de aniversário."
    end
    if aluno.esta_adiantado?
      mensagem_sonora << "aguarde_um_instante|"
      error << "Aguarde um instante para começar seu treinamento em seu horário. Agradecemos!"
    elsif aluno.esta_atrasado?
      mensagem_sonora << "voce_esta_atrasado|"
      error << ("Você está atrasado " << aluno.minutos_atrasados << " minutos. Procure não se atrasar novamente!")
    else
      mensagem_sonora << "parabens_pontualidade|"
      notice << "Parabéns pela sua pontualidade!"
    end
    if aluno.primeira_aula?
      mensagem_sonora << "bem_vindo|"
      notice << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
    end

      if aluno.faltou_aula_passada_e_nao_justificou?
        mensagem_sonora << "voce_faltou|"
        error << "Você faltou aula passada e não justificou."
      elsif aluno.faltou_aula_passada_e_justificou?
        mensagem_sonora << "justificou_aula_passada|"
        notice << "Você faltou aula passada e justificou."
      end

      if @matricula_standby
        mensagem_sonora << "Matrícula em estado inativo."
        notice << "Matrícula em estado inativo."
      end

    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?


    render :text => [saudacao, aluno.nome, aluno.foto, flash[:notice], flash[:error], chegada, mensagem_sonora].join(";") and return
  end

  def marcar_falta
    (hoje_eh_feriado?) ? gerar_falta(true) : gerar_falta(false)

    render :nothing => true
  end

  def gerar_falta eh_feriado
    today = (Rails.env.production?) ? (Time.now) : Time.now
    horarios = HorarioDeAula.joins(:matricula).joins("INNER JOIN pessoas ON matriculas.pessoa_id=pessoas.id")
    horarios = horarios.where(:"horarios_de_aula.dia_da_semana" => today.wday)
    horarios = horarios.where("data_inicio <= ? and (data_fim is null or data_fim >= ? and (standby is null or standby is false))", today.to_date, today.to_date)
    horarios = horarios.where("((cast(substr(horario,1,2) as int4) * 3600) + (cast(substr(horario,4,2) as int4) * 60)) + 180 < ((?) * 3600 + (?) * 60)", today.hour, today.min)
    horarios.each do |horario|
      aluno_id = horario.matricula.pessoa.id
      if Presenca.where(:pessoa_id => aluno_id).where(:data => today.to_date, :horario => horario.horario).blank?
        falta = Presenca.create(:pessoa_id => aluno_id, :data => today.to_date, :horario => horario.horario, :presenca => false, :tem_direito_a_reposicao => false)
        if eh_feriado
          falta.build_justificativa_de_falta(:descricao => "feriado")
          falta.save
        end
      end
    end
  end

  def hoje_eh_feriado?
    current_date = (Time.now)
    feriado = Feriado.where(:dia => current_date.day).where(:mes => current_date.month)
    ok = false
    if not feriado.blank?
      feriado = feriado[0]
      if feriado.repeticao_anual or feriado.ano == current_date.year
        ok = true
      end
    end
    ok
  end
end
