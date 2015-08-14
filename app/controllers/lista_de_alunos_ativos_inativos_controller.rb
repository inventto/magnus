# -*- encoding : utf-8 -*-
#coding: utf-8
class ListaDeAlunosAtivosInativosController < ApplicationController

  def ativos_inativos
    conditions = [[]]
    ano = params[:anos]
    if params[:ativos_matriculados] == "on"
      if !ano.blank?
        conditions[0] << "exists (select 1 from matriculas where 
          (inativo_desde is null or not (extract (year from inativo_desde)) ="+ano+" and 
          (extract (year from inativo_desde)) ="+ano+") and 
          pessoa_id = pessoas.id and data_fim is null)"
      else
      conditions[0] << "exists (select 1 from matriculas 
        where (inativo_desde is null or not 
        (now() between inativo_desde and 
        coalesce(inativo_ate, now()))) and 
        pessoa_id = pessoas.id and (data_fim is null or data_fim >= now()))"
      end
    end
    if params[:inativos] == "on"
      if !ano.blank?
        conditions[0] << "exists (select 1 from matriculas where 
          ((extract (year from inativo_desde)) ="+ano+" and 
          (extract (year from inativo_desde)) ="+ano+") and 
          pessoa_id = pessoas.id and data_fim is null)"
      else
        conditions[0] << "exists (select 1 from matriculas
          where (now() between inativo_desde and 
          coalesce(inativo_ate, now()) and data_fim is null) 
          and pessoa_id = pessoas.id)"
      end
    end
    if params[:interrompidos] == "on"
      if !ano.blank?
        conditions[0] << "exists (select 1 from matriculas where (extract (year from data_fim) = "+ano+") and pessoa_id = pessoas.id)"
      else
        conditions[0] << "not exists (select 1 from matriculas where data_fim is null and pessoa_id = pessoas.id)"
      end
    end

    conditions[0] = conditions[0].join(" or ")
    @alunos = Pessoa.where(conditions).order(:nome)
  end
end
