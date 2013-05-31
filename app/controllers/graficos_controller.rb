class GraficosController < ApplicationController
  def index
    @matriculas = Matricula.where("data_fim is not null")
  end
end
