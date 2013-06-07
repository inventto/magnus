#coding: utf-8
class RegistroPresencaController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def saudacao
      @saudacao = ""
      if (hora = Time.now.hour) < 12.hours
        @saudacao << "Bom Dia "
      elsif hora > 12.hours and hora < 18.hours
        @saudacao << "Boa Tarde "
      else
        @saudacao << "Boa Noite "
      end
      @saudacao << @aluno.nome
  end

  def registrar
    begin
      if params[:codigo].blank?
        flash[:error] = "Código do Aluno Inválido ou Aluno sem matrícula!"
        redirect_to "/registro_presenca"
        return
      else
        @aluno = Aluno.joins(:matricula).find_by_codigo_de_acesso(params[:codigo])
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
    saudacao
    @mensagem_sonora = ""
    notice = []
    error = []
    if @aluno.esta_fora_de_horario?
      @mensagem_sonora = "Você está fora do horário da matrícula!"
      flash[:error] = "Você está fora do horário da matrícula!"
      return
    end
    if @aluno.esta_no_dia_errado?
      @mensagem_sonora = "dia_errado|"
      flash[:error] = "Hoje não é seu dia normal de aula!"
      return
    end
    if @aluno.aula_de_reposicao?
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
    if @aluno.faltou_aula_passada_sem_justificativa?
      @mensagem_sonora << "Você faltou aula passada e não justificou."
      error << "Você faltou aula passada e não justificou."
    end
    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?
  end

  def marcar_falta
    if not hoje_eh_feriado?
      hora_certa = (Time.now + Time.zone.utc_offset)
      horarios = HorarioDeAula.joins(:matricula).joins("INNER JOIN alunos ON matriculas.aluno_id=alunos.id").where(:"horarios_de_aula.dia_da_semana" => hora_certa.wday).where("data_inicio <= current_date and (data_fim is null or data_fim >= current_date)").where("((cast(substr(horario,1,2) as int4) * 3600) + (cast(substr(horario,4,2) as int4) * 60)) + 180 < ((?) * 3600 + (?) * 60)", hora_certa.hour, hora_certa.min)
      horarios.each do |horario|
        aluno_id = horario.matricula.aluno.id
        if Presenca.where(:aluno_id => aluno_id).where(:data => Date.today).blank?
          Presenca.create(:aluno_id => aluno_id, :data => Date.today, :horario => horario.horario, :presenca => false)
        end
      end
    end
    render :nothing => true
  end

  def hoje_eh_feriado?
    current_date = Date.today
    feriado = Feriado.where(:dia => current_date.day).where(:mes => current_date.month)
    if not feriado.blank?
      feriado = feriado[0]
      if feriado.repeticao_anual or feriado.ano == current_date.year
        return true
      end
    end
    false
  end

  def registro_android
    begin
      @aluno = Aluno.joins(:matricula).find_by_codigo_de_acesso(params[:codigo])
      if not @aluno
        raise ""
      end
    rescue
      flash[:error] = "Código do Aluno Inválido ou Aluno sem matrícula!"
      render :text => [flash[:error], "codigo_invalido"].join("|") and return
    end

    params[:time_millis] = nil if not params[:time_millis]
    if not @aluno.registrar_presenca params[:time_millis]
      flash[:error] = "Aluno já possui Presença Registrada!"
      render :text => [flash[:error], "aluno_possui_presenca"].join("|") and return
    end
    return if not params[:time_millis].nil? # caso venha o time_millis significa que nada será exibido ao usuário, logo não havendo necessidade de executar os códigos abaixo

    saudacao
    @mensagem_sonora = ""
    notice = []
    error = []
    if @aluno.esta_fora_de_horario?
      @mensagem_sonora = "fora_de_horario|"
      flash[:error] = "Você está fora do horário da matrícula!"
      render :text => [@saudacao, @aluno.nome, @aluno.foto, flash[:notice], flash[:error], @mensagem_sonora].join(";") and return
    end
    if @aluno.esta_no_dia_errado?
      @mensagem_sonora = "dia_errado|"
      flash[:error] = "Hoje não é seu dia normal de aula!"
      render :text => [@saudacao, @aluno.nome, @aluno.foto, flash[:notice], flash[:error], @mensagem_sonora].join(";") and return
    end
    if @aluno.aula_de_reposicao?
      @mensagem_sonora = "aula_de_reposicao|"
      notice << "Hoje é sua aula de reposição!"
    end
    if @aluno.esta_de_aniversario_essa_semana?
      @mensagem_sonora << "parabens_semana|"
      notice << "Parabéns! Essa semana você está de aniversário!"
    elsif @aluno.esta_de_aniversario_esse_mes?
      @mensagem_sonora << "parabens_mes|"
      notice << "Parabéns! Esse mês você está de aniversário."
    end
    if @aluno.esta_adiantado?
      @mensagem_sonora << "aguarde_um_instante|"
      error << "Aguarde um instante para começar seu treinamento em seu horário. Agradecemos!"
    elsif @aluno.esta_atrasado?
      @mensagem_sonora << "voce_esta_atrasado|"
      error << ("Você está atrasado " << @aluno.minutos_atrasados << " minutos. Procure não se atrasar novamente!")
    else
      @mensagem_sonora << "parabens_pontualidade|"
      notice << "Parabéns pela sua pontualidade!"
    end
    if @aluno.primeira_aula?
      @mensagem_sonora << "bem_vindo|"
      notice << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
    end
    if @aluno.faltou_aula_passada_sem_justificativa?
      @mensagem_sonora << "voce_faltou|"
      error << "Você faltou aula passada e não justificou."
    end
    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?

    render :text => [@saudacao, @aluno.nome, @aluno.foto, flash[:notice], flash[:error], @mensagem_sonora].join(";") and return
  end
end
