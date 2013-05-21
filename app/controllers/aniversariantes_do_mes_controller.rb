class AniversariantesDoMesController < ApplicationController
  def aniversariantes
    @aniversariantes = Aluno.where("extract(month from data_nascimento) = extract(month from now())").group(:data_nascimento, :id)
    @aniversariantes_de_hoje = @aniversariantes.where("extract(day from data_nascimento) = extract(day from current_date)")
    @aniversariantes_do_mes = @aniversariantes.where("extract(day from data_nascimento) <> extract(day from current_date)")
  end
end
