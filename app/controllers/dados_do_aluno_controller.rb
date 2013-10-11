#coding: utf-8
class DadosDoAlunoController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def show
    error_message = []
    if params[:data].blank?
      error_message << "Campo <strong>Data</strong> deve ser informado!"
    end
    if params[:codigo_de_acesso].blank?
      error_message << "Campo <strong>Código de acesso</strong> deve ser informado!"
    end
    if not error_message.blank?
      msg = error_message.join("<br/>")
      flash[:error] = msg.html_safe
      render "/dados_do_aluno/index" and return
    else
      data = params[:data].to_date
      codigo = params[:codigo_de_acesso]

      @aluno = Pessoa.find_by_data_nascimento_and_codigo_de_acesso(data, codigo)

      if @aluno.nil?
        msg = "Aluno não encontrado! Verifique os dados informados."
        flash[:error] = msg.html_safe
        render "/dados_do_aluno/index" and return
      end
    end
  end
end
