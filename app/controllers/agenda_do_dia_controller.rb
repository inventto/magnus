# -*- encoding : utf-8 -*-
class AgendaDoDiaController < ApplicationController

  def agenda
    @data_inicial = (Time.now).to_date
    @data_final = @data_inicial
    load_agenda
  end

  def filtrar
    @data_inicial = Date.parse(params[:"data_inicial"])
    @data_final = Date.parse(params[:"data_final"])

    if @data_inicial <= @data_final
      load_agenda
    else
      flash[:error] = "Data Inicial deve ser menor ou igual a Data Final!"
    end

    render 'agenda'
  end

  def load_agenda
    agenda = consultar_agenda
    presencas = consultar_presencas_passe_livre

    unir_horarios(agenda, presencas)

    agrupa_e_ordena
  end

  def consultar_agenda
    agenda = HorarioDeAula.joins(:matricula).joins("INNER JOIN pessoas ON matriculas.pessoa_id=pessoas.id").where("matriculas.data_fim is null OR matriculas.data_fim >= NOW()")
    if @data_inicial == @data_final
      dia_da_semana = @data_inicial.wday
      agenda = agenda.where(:"horarios_de_aula.dia_da_semana" => dia_da_semana)
    end

    agenda
  end

  def consultar_presencas_passe_livre
    Presenca.select("presencas.*, EXTRACT( DOW FROM data ) AS dia_da_semana").where("data >= '#{@data_inicial}' and data <= '#{@data_final}'").com_matricula_ativa
  end

  def unir_horarios agenda, presencas
    @agenda_do_dia = []

    @agenda_do_dia += agenda
    @agenda_do_dia += presencas
    @agenda_do_dia.uniq!
  end

  def agrupa_e_ordena
    @agenda_do_dia = @agenda_do_dia.group_by{ |a| a.dia_da_semana.to_i }

    @pontos_do_dia =  RegistroDePonto.entre(@data_inicial, @data_final).order("data, hora_de_chegada").select do |registro|
      registro.pessoa.eh_professor?
    end

    @agenda_do_dia = @agenda_do_dia.sort

    @agenda_do_dia.each do |k, agenda|
      agenda.sort! {|x, y| (x.horario[0..1].to_i * 3600 + x.horario[1..2].to_i * 60) <=> (y.horario[0..1].to_i * 3600 + y.horario[1..2].to_i * 60)}
    end
  end
end
