class AgendaDoDiaController < ApplicationController

  def agenda
    @data_inicial = (Time.now).to_date
    @data_final = @data_inicial
    load_agenda
  end

  def filtrar
    @data_inicial = Date.parse(params[:"data-inicial"])
    @data_final = Date.parse(params[:"data-final"])

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

    realocacao_do_dia = presencas.where(:realocacao => true)

    fora_de_horario = presencas.where(:fora_de_horario => true)

    aula_extra = presencas.where(:aula_extra => true)

    unir_horarios(agenda, presencas, realocacao_do_dia, fora_de_horario, aula_extra)

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
    presencas = Presenca.select("presencas.*, EXTRACT( DOW FROM data ) AS dia_da_semana").joins(:pessoa)

    if @data_inicial == @data_final
      presencas = presencas.where(:data => @data_inicial)
    else
      presencas = presencas.where("data >= '#{@data_inicial}' and data <= '#{@data_final}'")
    end

    presencas.delete_if { |p| not p.pessoa.passe_livre? }
    presencas
  end

  def unir_horarios agenda, presencas, realocacao, fora_de_horario, aula_extra
    @agenda_do_dia = []

    @agenda_do_dia += agenda
    @agenda_do_dia += presencas
    @agenda_do_dia += realocacao
    @agenda_do_dia += fora_de_horario
    @agenda_do_dia += aula_extra
    @agenda_do_dia.uniq!
  end

  def agrupa_e_ordena
    @agenda_do_dia = @agenda_do_dia.group_by{ |a| a.dia_da_semana.to_i }

    @pontos_do_dia =  RegistroDePonto.entre(@data_inicial, @data_final).order("data, hora_de_chegada")

    @agenda_do_dia = @agenda_do_dia.sort

    @agenda_do_dia.each do |k, agenda|
      agenda.sort! {|x, y| (x.horario[0..1].to_i * 3600 + x.horario[1..2].to_i * 60) <=> (y.horario[0..1].to_i * 3600 + y.horario[1..2].to_i * 60)}
    end
  end
end
