#coding: utf-8
class AlunosController < ApplicationController
  active_scaffold :aluno do |conf|
    conf.columns[:endereco].label = "Endereço"
    conf.columns[:cpf].label = "CPF"
    conf.columns[:telefones].label = "Telefone"
    conf.columns[:codigo_de_acesso].label = "Código de Acesso"
    conf.columns = [:id, :foto, :nome, :cpf, :email, :sexo, :data_nascimento, :codigo_de_acesso, :foto, :endereco, :telefones]
    conf.columns[:data_nascimento].options[:format] = :default
    conf.columns[:sexo].form_ui = :select
    conf.columns[:sexo].options = {:options => Aluno::SEX.map(&:to_sym)}
    conf.columns[:endereco].allow_add_existing = false
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:nome, :cpf, :email, :sexo, :data_nascimento]
  end

  def gerar_codigo_de_acesso
    codigo = ""
    if data = params[:nascimento] and not data.blank?
      nome = params[:nome].downcase

      codigo = data[0..1] << data[3..4] << data[8..9]

      if codigo_existe? codigo
        for i in 0..(codigo.length - 1)
          for j in 0..(nome.length - 1)
            codigo[i] = nome[j]
            break unless existe = codigo_existe?(codigo)
          end
          break unless existe
        end
      end
    else
    end

    render :text => codigo
  end

  def codigo_existe?(codigo)
    Aluno.find_by_codigo_de_acesso(codigo)
  end
end
