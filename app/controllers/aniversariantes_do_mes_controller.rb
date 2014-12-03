# -*- encoding : utf-8 -*-
class AniversariantesDoMesController < ApplicationController
  def aniversariantes
    @aniversariantes = Pessoa.de_aniversario_no_mes(Time.now.month)
    @mes = Date.today.month
    if @mes == 12
      @mes = 0
    end
  end

  def filtrar
    @mes = params[:mes]
    @aniversariantes = Pessoa.de_aniversario_no_mes(@mes)

    render "/aniversariantes_do_mes/aniversariantes"
  end
end
