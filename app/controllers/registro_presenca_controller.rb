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
      flash[:error] = "Erro ao Registrar Presença!"
      redirect_to "/registro_presenca"
      return
    end

    notice = []
    if @aluno.aula_de_reposicao?
      flash[:notice] = "Hoje não é seu dia normal de aula!"
      return
    end
    if @aluno.esta_de_aniversario_essa_semana?
      notice << "Feliz Aniversário!"
    end
    if @aluno.esta_adiantado?
      notice << "Aguarde... sua aula começa em aproximadamente " << @aluno.quantos_min_adiantado << " minutos! "
    elsif @aluno.esta_atrasado?
      notice << "Atenção! Você está atrasado! Procure chegar mais cedo na próxima aula!"
    else
      notice << "Bem Vindo à Magnus Personal...Você chegou no horário!"
    end
    if @aluno.primeira_aula?
      notice << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
    end
    flash[:notice] = notice.join("<br/><br/>").html_safe
  end
end
