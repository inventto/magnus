class AniversariantesDoMesController < ApplicationController
  def aniversariantes
    @aniversariantes = Aluno.where("extract(month From data_nascimento) = extract(month from now())").group(:data_nascimento, :id)
  end
end
