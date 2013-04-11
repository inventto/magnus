#coding: utf-8
class RegistroPresencaController < ApplicationController
  skip_before_filter :authenticate_user!#, :only => [:index, :registrar]

  def index
  end

  def registrar
    aluno = Aluno.find params[:id]
    if not aluno.registrar_presenca
      flash[:notice] = "erro!"
      return
    end

    notice = []
    if aluno.esta_de_aniversario_essa_semana?
      notice << "Feliz Aniversário!"
    end
    if aluno.esta_adiantado?
      notice << "Aguarde... sua aula começa em aproximadamente " << aluno.quantos_min_adiantado << " minutos! "
    elsif aluno.esta_atrasado?
      notice << "Atenção! Você está atrasado! Procure chegar mais cedo na próxima aula!"
    else
      notice << "Bem Vindo à Magnus Personal...Você chegou no horário!"
    end
    if aluno.primeira_aula?
      notice << "Bem Vindo à Magnus Personal...Hoje é sua primeira aula!"
    end
    #if aluno.aula_de_reposicao?
     # notice << "Hoje não é seu dia normal de aula!"
    #end
    flash[:notice] = notice.join("<br/>").html_safe
  end
end
