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
      @aluno = Aluno.joins(:matricula).find params[:id]
    rescue
      flash[:error] = "Código do Aluno Inválido ou Aluno sem matrícula!"
      redirect_to "/registro_presenca"
      return
    end

    if not @aluno.registrar_presenca
      flash[:error] = "Aluno já possui Presença Registrada!"
      redirect_to "/registro_presenca"
      return
    end
    saudacao
    @mensagem_sonora = ""
    notice = []
    error = []
    if @aluno.aula_de_reposicao?
      @mensagem_sonora = "Hoje não é seu dia normal de aula!"
      flash[:notice] = @mensagem_sonora
      return
    end
    if @aluno.esta_de_aniversario_essa_semana?
      @mensagem_sonora << "Parabéns! Essa semana você está de aniversário!"
      notice << @mensagem_sonora
    elsif @aluno.esta_de_aniversario_esse_mes?
      @mensagem_sonora << "Parabéns! Esse mês você está de aniversário."
      notice << @mensagem_sonora
    end
    if @aluno.esta_adiantado?
      @mensagem_sonora << "Aguarde um instante para começar seu treinamento em seu horário. Agradecemos!"
      error << @mensagem_sonora
    elsif @aluno.esta_atrasado?
      @mensagem_sonora << ("Você está atrasado " << @aluno.minutos_atrasados << " minutos. Procure não se atrasar novamente!")
      error << @mensagem_sonora
    else
      @mensagem_sonora << "Parabéns pela sua pontualidade!"
      notice << @mensagem_sonora
    end
    if @aluno.primeira_aula?
      @mensagem_sonora << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
      notice << @mensagem_sonora
    end
    if @aluno.faltou_aula_passada_sem_justificativa?
      @mensagem_sonora << "Você faltou aula passada e não justificou."
      error << @mensagem_sonora
    end
    flash[:notice] = notice.join("<br/><br/>").html_safe
    flash[:error] = error.join("<br/><br/>").html_safe unless error.blank?
  end

  def marcar_falta
    horarios = HorarioDeAula.joins(:matricula).joins("INNER JOIN alunos ON matriculas.aluno_id=alunos.id").where(:"horarios_de_aula.dia_da_semana" => Time.now.wday).where("data_inicio <= current_date and data_fim >= current_date").where("((cast(substr(horario,1,2) as int4) * 3600) + (cast(substr(horario,4,2) as int4) * 60)) + 180 < (EXTRACT(HOUR FROM CURRENT_TIME) * 3600 + EXTRACT(MINUTE FROM CURRENT_TIME) * 60)")
    horarios.each do |horario|
      aluno_id = horario.matricula.aluno.id
      if Presenca.where(:aluno_id => aluno_id).where(:data => Date.today).blank?
        Presenca.create(:aluno_id => aluno_id, :data => Date.today, :horario => horario.horario, :presenca => false)
      end
    end
    render :nothing => true
  end

  def registro_android
    registrar
    render :text => [@saudacao, flash[:notice], flash[:error], @mensagem_sonora].join(";")
  end
end
