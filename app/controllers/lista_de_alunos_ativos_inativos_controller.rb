#coding: utf-8
class ListaDeAlunosAtivosInativosController < ApplicationController

  def ativos_inativos
    conditions = [[]]
    if params[:ativos_matriculados] == "on"
      conditions[0] << "exists (select 1 from matriculas where not (now() between inativo_desde and coalesce(inativo_ate, now()) and data_fim is null) and pessoa_id = pessoas.id)"
    end
    if params[:inativos] == "on"
      conditions[0] << "exists (select 1 from matriculas where (now() between inativo_desde and coalesce(inativo_ate, now()) and data_fim is null) and pessoa_id = pessoas.id)"
    end
    if params[:interrompidos] == "on"
      conditions[0] << "not exists (select 1 from matriculas where data_fim is null and pessoa_id = pessoas.id)"
    end

    conditions[0] = conditions[0].join(" or ")
    @alunos = Pessoa.where(conditions).order(:nome)
  end
end
