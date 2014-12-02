# -*- encoding : utf-8 -*-
#encoding: utf-8
module InteresseNoHorarioHelper
  def get_nomes_nos(horarios)
    horarios[0,4].collect do |registro|
      ultimo_nome = []
      ultimo_nome = registro.matricula.pessoa.segundo_nome.split(" ")
      ultimo_nome = ultimo_nome[ultimo_nome.length - 1][0]
      content_tag(:li,  "#{registro.matricula.pessoa.primeiro_nome} #{ultimo_nome}.", class: "nome_interessado" )
    end.join('').html_safe
  end

  def esta_englobado_no?(dia_da_semana, dias_da_aula)
    dia_da_semana == dias_da_aula.first.dia_da_semana
  end

  def esta_contido_na(hora_atual, hora_da_aula)
    if hora_atual and hora_da_aula
      format("%.2d", hora_atual).eql? hora_da_aula[0..1]
    end
  end

end
