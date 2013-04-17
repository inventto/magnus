#coding: utf-8
class RegistroPresencaController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
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

    notice = []
    error = []
    if @aluno.aula_de_reposicao?
      flash[:notice] = "Hoje não é seu dia normal de aula!"
      return
    end
    if @aluno.esta_de_aniversario_esse_mes?
      notice << "Parabéns! Esse mês você está de aniversário."
    elsif @aluno.esta_de_aniversario_essa_semana?
      notice << "Parabéns! Essa semana você está de aniversário!"
    end
    if @aluno.esta_adiantado?
      error << "Aguarde um instante para começar seu treinamento em seu horário. Agradecemos!"
    elsif @aluno.esta_atrasado?
      error << ("Infelizmente está atrasado " << @aluno.minutos_atrasados << " minutos para seu treinamento, lembramos que o seu treino não será prorrogado. Procure não se atrasar novamente!")
    else
      notice << "Parabéns pela sua pontualidade!"
    end
    if @aluno.primeira_aula?
      notice << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
    end
    if @aluno.faltou_aula_passada_sem_justificativa?
      error << "Você faltou aula passada e não justificou."
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
end
