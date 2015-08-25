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

    if params[:objetivo_primario] == "on"
      conditions[0] << "exists(select nome, objetivo_primario from matriculas 
      where(matriculas.objetivo_primario in 
      (select matriculas.objetivo_primario from matriculas group by matriculas.objetivo_primario)) and pessoa_id = pessoas.id and 
      (data_fim is null or data_fim >= now())order by 2, 1)"
    end
     
    conditions[0] = conditions[0].join(" or ")
    @alunos = Pessoa.where(conditions).order(:nome)
    @alunos.sort! {|p1, p2|  valida_objetivo_primario(p1).to_s.downcase <=> valida_objetivo_primario(p2).to_s.downcase}
  end

  def valida_objetivo_primario(pessoa)
    pessoa.matriculas.valida.first.nil? ? "" : pessoa.matriculas.valida.first.objetivo_primario
  end
end
