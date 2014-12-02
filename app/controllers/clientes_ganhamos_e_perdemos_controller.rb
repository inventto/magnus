# -*- encoding : utf-8 -*-
class ClientesGanhamosEPerdemosController < ApplicationController
  def index
    @total_alunos_que_entraram = Hash.new{0}
    @years = {}
    @matriculas = Matricula.where("data_fim is not null").group_by{|m| m.data_fim.month }
    @matriculas.each do |mes, m|
      @matriculas[mes] = m.group_by do |m1|
        y=m1.data_fim.year
        @years[y] = 0
        @total_alunos_que_entraram[y] = 0
        y
      end
    end
    clientes_que_ganhamos()
  end

  def clientes_que_ganhamos()
    @clientes_que_entraram = Matricula.where("data_inicio <= ?", Time.now).group_by{|data| [data.data_inicio.month, data.data_inicio.year]}
  end
end
