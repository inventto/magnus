class AniversariantesDoMesController < ApplicationController
  def aniversariantes
    @aniversariantes = Aluno.where("extract(month from data_nascimento) = extract(month from now())").group(:data_nascimento, :id).order("extract(day from data_nascimento)")
    @mes = Date.today.month
  end

  def filtrar
    @mes = params[:mes]
    @aniversariantes = Aluno.where("extract(month from data_nascimento) = #{@mes}").group(:data_nascimento, :id).order("extract(day from data_nascimento)")

    render "/aniversariantes_do_mes/aniversariantes"
  end
end
