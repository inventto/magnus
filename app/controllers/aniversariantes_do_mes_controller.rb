class AniversariantesDoMesController < ApplicationController
  def aniversariantes
    @aniversariantes = Pessoa.de_aniversario_no_mes("extract(month from now())")
    @mes = Date.today.month
  end

  def filtrar
    @mes = params[:mes]
    @aniversariantes = Pessoa.de_aniversario_no_mes(@mes)

    render "/aniversariantes_do_mes/aniversariantes"
  end
end
