class GraficosController < ApplicationController
  def index
    @meses = Date::MONTHNAMES.dup
    @meses << @meses.delete_at(0)
    @meses.compact!

    @matriculas = Matricula.all
    @desistentes = Matricula.where("data_fim is not null")

    @desistentes_por_mes = @desistentes.group_by{|m| m.data_fim.month}
    @desistentes_por_mes_e_ano = @desistentes.group_by{|m| m.data_fim.strftime("%y")+"/#{m.data_fim.month}"}

    @matriculas_por_mes_e_ano = @matriculas.group_by{|m| m.data_inicio.strftime("%y")+"/#{m.data_inicio.month}"}

    @total_clientes_perdidos = @desistentes.size
    @clientes_que_perdemos_por_mes = (1..12).collect do |mes|
      if @desistentes_por_mes[mes]
        @desistentes_por_mes[mes].size
      else
        0
      end
    end

    @total_clientes_perdidos_dia_da_semana = 0
    @clientes_que_perdemos_por_dia_da_semana = (0..6).collect do |semana|
      soma = 0
      @desistentes.each do |d|
         if not d.hora_da_aula(semana).blank?
           @total_clientes_perdidos_dia_da_semana += 1
           soma += 1
         end
      end
      soma
    end

   @rotatividade_de_clientes = []
   @rotatividade_keys = @matriculas_por_mes_e_ano.keys.sort
   @rotatividade_keys.each_with_index do |key, i|
     if @desistentes_por_mes_e_ano[i]
       @rotatividade_de_clientes[i] = @matriculas_por_mes_e_ano[key].size - @desistentes_por_mes_e_ano[key].size
     else
       @rotatividade_de_clientes[i] = @matriculas_por_mes_e_ano[key].size
     end
   end
  end
end
