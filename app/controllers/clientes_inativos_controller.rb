class ClientesInativosController < ApplicationController
  def index
    @matriculas = Matricula.where("data_fim is not null")
  end

  def filtrar
    puts params
  end
end
