#coding: utf-8
class AlunosController < ApplicationController
  active_scaffold :aluno do |conf|
    conf.columns[:endereco].label = "Endereço"
    conf.columns[:cpf].label = "CPF"
    conf.columns[:telefones].label = "Telefone"
    conf.columns[:codigo_de_acesso].label = "Código de Acesso"
    conf.columns = [:id, :foto, :nome, :cpf, :email, :sexo, :data_nascimento, :codigo_de_acesso, :foto, :endereco, :telefones]
    conf.show.columns << :presencas
    conf.columns[:data_nascimento].options[:format] = :default
    conf.columns[:sexo].form_ui = :select
    conf.columns[:sexo].options = {:options => Aluno::SEX.map(&:to_sym)}
    conf.columns[:endereco].allow_add_existing = false
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:nome, :cpf, :email, :sexo, :data_nascimento]
  end

  def justificar_falta
    error = ""

    if params[:horario].blank?
      error << "<strong>Horário da Aula</strong> não pode ficar vazio!\n"
    end
    if params[:justificativa].blank?
      error << "<strong>Justificativa</strong> não pode ficar vazio!"
    end
    if not error.blank?
      render :text => error and return
    end

    presenca = Presenca.create(:aluno_id => params[:aluno_id].to_i, :data => params[:data], :horario => params[:horario], :presenca => false, :reposicao => false, :fora_de_horario => false)
    JustificativaDeFalta.create(:descricao => params[:justificativa], :presenca_id => presenca.id)

    render :text => error
  end

  def gerar_codigo_de_acesso
    codigo = ""

    if not aluno_possui_codigo_de_acesso?
      if data = params[:nascimento] and not data.blank?
        codigo = data[0..1] << data[3..4] << data[8..9]
        count = 4
        while(codigo_existe?(codigo))
          codigo[0] = count.to_s
          count += 1
        end
      end
    end

    render :text => codigo
  end

  def aluno_possui_codigo_de_acesso?
    return false if params[:id].blank?
    aluno = Aluno.find(params[:id])
    if aluno.codigo_de_acesso.blank?
      return false
    else
      return true
    end
  end

  def codigo_existe?(codigo)
    Aluno.find_by_codigo_de_acesso(codigo)
  end
end
