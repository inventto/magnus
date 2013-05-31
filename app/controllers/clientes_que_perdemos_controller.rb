class ClientesQuePerdemosController < ApplicationController
  def index
    @anos = {}
    @matriculas = Matricula.where("data_fim is not null").group_by{|m| m.data_fim.month }
    @matriculas.each do |mes, m|
      @matriculas[mes] = m.group_by do |m1|
        y=m1.data_fim.year
        @anos[y] = 0
        y
      end
    end
  end
end
