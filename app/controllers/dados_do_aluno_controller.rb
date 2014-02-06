#encoding: utf-8
class DadosDoAlunoController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def show
    error_message = []
    if params[:nome].blank?
      error_message << "Campo <strong>Nome</strong> deve ser informado!"
    elsif params[:nome].length < 3
      error_message << "<strong>Nome</strong> deve possuir ao menos 3 caracteres!"
    end
    if params[:codigo_de_acesso].blank?
      error_message << "Campo <strong>Código de acesso</strong> deve ser informado!"
    end
    if not error_message.blank?
      msg = error_message.join("<br/>")
      flash[:error] = msg.html_safe
      render "/dados_do_aluno/index" and return
    else
      nome = params[:nome]
      codigo = params[:codigo_de_acesso]

      @aluno = Pessoa.where("nome ILIKE '%#{nome.strip.gsub(/\s/, "%")}%'").where(:codigo_de_acesso => codigo)

      if @aluno.blank?
        msg = "Aluno não encontrado! Verifique os dados informados."
        flash[:error] = msg.html_safe
        render "/dados_do_aluno/index" and return
      else
        @aluno = @aluno.first
      end
    end
  end
end
