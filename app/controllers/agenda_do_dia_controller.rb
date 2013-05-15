class AgendaDoDiaController < ApplicationController

  def agenda
    @data_inicial = Date.today
    @data_final = @data_inicial
    load_agenda
  end

  def filtrar
    @data_inicial = Date.parse(params[:"data-inicial"])
    @data_final = Date.parse(params[:"data-final"])

    load_agenda

    render 'agenda'
  end

  def load_agenda
    agenda = consulta_agenda

    reposicao_do_dia = consulta_reposicao

    concatena_horarios(agenda, reposicao_do_dia)

    agrupa_e_ordena
  end

  def consulta_reposicao
    reposicao_do_dia = Presenca.select("presencas.*, EXTRACT( DOW FROM data ) AS dia_da_semana").joins(:aluno)

    if @data_inicial == @data_final
      reposicao_do_dia = reposicao_do_dia.where(:data => @data_inicial)
    else
      reposicao_do_dia = reposicao_do_dia.where("data >= '#{@data_inicial}' and data <= '#{@data_final}'")
    end

    reposicao_do_dia = reposicao_do_dia.where(:reposicao => true)
  end

  def consulta_agenda
    agenda = HorarioDeAula.joins(:matricula).joins("INNER JOIN alunos ON matriculas.aluno_id=alunos.id")

    if @data_inicial == @data_final
      dia_da_semana = @data_inicial.wday
      agenda = agenda.where(:"horarios_de_aula.dia_da_semana" => dia_da_semana)
    end

    agenda
  end

  def agrupa_e_ordena
    @agenda_do_dia = @agenda_do_dia.group_by{ |a| a.dia_da_semana.to_i }

    @agenda_do_dia.each do |k, agenda|
      agenda.sort! {|x, y| (x.horario[0..1].to_i * 3600 + x.horario[1..2].to_i * 60) <=> (y.horario[0..1].to_i * 3600 + y.horario[1..2].to_i * 60)}
    end
  end

  def concatena_horarios agenda, reposicao
    @agenda_do_dia = []

    agenda.each do |a|
      @agenda_do_dia << a
    end

    reposicao.each do |r|
      @agenda_do_dia << r
    end
  end
end
