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
        @aluno = Pessoa.joins(:matricula).find_by_codigo_de_acesso(params[:codigo])
        if not @aluno
          raise ""
        end
      end
    rescue
      flash[:error] = "Código do Aluno Inválido ou Aluno sem matrícula!"
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
     if @aluno.faltou_aula_passada_e_nao_justificou?
      @mensagem_sonora << "Você faltou aula passada e não justificou."
      error << "Você faltou aula passada e não justificou."
    elsif @aluno.faltou_aula_passada_e_justificou?
      @mensagem_sonora << "Você faltou aula passada e justificou."
      notice << "Você faltou aula passada e justificou."
    end
    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?
  end

  def get_nome_do_periodo
    periodo = get_periodo
    if periodo[:manha]
      return "Manhã"
    elsif periodo[:tarde]
      return "Tarde"
    else
      return "Noite"
    end
  end

  def get_periodo
    periodo = {:manha => false, :tarde => false, :noite => false}
    if (hora = (Time.now + Time.zone.utc_offset).hour) < 12.hours
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
    if periodo[:manha]
      saudacao << "Bom Dia "
    elsif periodo[:tarde]
      saudacao << "Boa Tarde "
    else
      saudacao << "Boa Noite "
    end
    saudacao << pessoa.nome
  end

  def despedida_ao pessoa
    periodo = get_periodo
    if periodo[:manha]
      return "Tenha uma Boa Tarde"
    else
      return "Tenha uma Boa Noite"
    end
  end

  def registrar_ponto_android
    begin
      employee = Pessoa.find_by_e_funcionario_and_codigo_de_acesso(true, params[:codigo])
      if not employee
        raise ""
      end
    rescue
      logger.warn("=== .: Código do Funcionário Inválido: #{params[:codigo]} às #{(Time.now + Time.zone.utc_offset)} :.")
      flash[:error] = "Código do Funcionário Inválido!"
      render :text => [flash[:error], "codigo_funcionario_invalido"].join("|") and return
    end

    mensagem_sonora = ""
    notice = []

    time_millis = (not params[:tim_millis]) ? nil : params[:time_millis]
    if not employee.registrar_ponto(time_millis)
      flash[:error] = "Funcionário já possui Ponto Registrado para o periodo da #{get_nome_do_periodo}!"
      render :text => [flash[:error], "funcionario_possui_presenca"].join("|") and return
    end
    return if not time_millis.nil?

    if employee.esta_de_aniversario_essa_semana?
      mensagem_sonora << "parabens_semana|"
      notice << "Parabéns! Essa semana você está de aniversário!"
    elsif employee.esta_de_aniversario_esse_mes?
      mensagem_sonora << "parabens_mes|"
      notice << "Parabéns! Esse mês você está de aniversário!"
    end

    flash[:notice] = notice.join("<br/><br/>").html_safe

    saudacao = (employee.chegada_de_horario?) ? saudacao_ao(employee) : despedida_ao(employee)

    render :text => [saudacao, employee.nome, employee.foto, flash[:notice], "", mensagem_sonora].join(";") and return
  end

  def registro_android
    begin
      aluno = Pessoa.joins(:matricula).find_by_codigo_de_acesso(params[:codigo])
      if not aluno
        raise ""
      end
    rescue
      logger.warn("=== .: Código do Aluno Inválido/Sem Matrícula: #{params[:codigo]} às #{(Time.now + Time.zone.utc_offset)} :.")
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

    if aluno.esta_fora_de_horario?
      mensagem_sonora = "fora_de_horario|"
      flash[:error] = "Você está fora do horário da matrícula!"
      render :text => [saudacao, aluno.nome, aluno.foto, flash[:notice], flash[:error], mensagem_sonora].join(";") and return
    end
    if aluno.esta_no_dia_errado?
      mensagem_sonora = "dia_errado|"
      flash[:error] = "Hoje não é seu dia normal de aula!"
      render :text => [saudacao, aluno.nome, aluno.foto, flash[:notice], flash[:error], mensagem_sonora].join(";") and return
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
    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?

    render :text => [saudacao, aluno.nome, aluno.foto, flash[:notice], flash[:error], mensagem_sonora].join(";") and return
  end

  def marcar_falta
    if not hoje_eh_feriado?
      data_certa = (Time.now + Time.zone.utc_offset)
      horarios = HorarioDeAula.joins(:matricula).joins("INNER JOIN pessoas ON matriculas.pessoa_id=pessoas.id")
      horarios = horarios.where(:"horarios_de_aula.dia_da_semana" => data_certa.wday)
      horarios = horarios.where("data_inicio <= ? and (data_fim is null or data_fim >= ?)", data_certa.to_date, data_certa.to_date)
      horarios = horarios.where("((cast(substr(horario,1,2) as int4) * 3600) + (cast(substr(horario,4,2) as int4) * 60)) + 180 < ((?) * 3600 + (?) * 60)", data_certa.hour, data_certa.min)
      horarios.each do |horario|
        aluno_id = horario.matricula.pessoa.id
        if Presenca.where(:pessoa_id => aluno_id).where(:data => data_certa, :horario => horario.horario).blank?
          Presenca.create(:pessoa_id => aluno_id, :data => data_certa, :horario => horario.horario, :presenca => false, :tem_direito_a_reposicao => false)
        end
      end
    end
    render :nothing => true
  end

  def hoje_eh_feriado?
    current_date = (Time.now + Time.zone.utc_offset)
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
