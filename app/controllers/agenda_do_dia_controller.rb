class AgendaDoDiaController < ApplicationController

  def agenda
    @data_inicial = Date.today
    @data_final = @data_inicial
    load_agenda
  end

  def filtrar
    @data_inicial = params[:"data-inicial"]
    @data_final = params[:"data-final"]

    load_agenda

    render 'agenda'
  end

  def load_agenda
    agenda_do_dia = HorarioDeAula.joins(:matricula).joins("INNER JOIN alunos ON matriculas.aluno_id=alunos.id")

    if @data_inicial == @data_final
      dia_da_semana = Date.parse(@data_inicial).wday rescue @data_inicial.wday
      agenda_do_dia = agenda_do_dia.where(:"horarios_de_aula.dia_da_semana" => dia_da_semana)
    end

    #agenda_do_dia = agenda_do_dia.where("data_inicio <= '#{@data_inicial}' and (data_fim >= '#{@data_final}' or data_fim is null)")
    agenda_do_dia = agenda_do_dia.where("data_fim >= '#{@data_final}' or data_fim is null")

#    agenda_do_dia = agenda_do_dia.where(:"horarios_de_aula.dia_da_semana" => Time.now.wday).where("data_inicio <= current_date and (data_fim >= current_date or data_fim is null)")

    reposicao_do_dia = Presenca.select("presencas.*, EXTRACT( DOW FROM data ) AS dia_da_semana").joins(:aluno)

    if @data_inicial == @data_final
      reposicao_do_dia = reposicao_do_dia.where(:data => @data_inicial)
    else
      reposicao_do_dia = reposicao_do_dia.where("data >= '#{@data_inicial}' and data <= '#{@data_final}'")
    end

    reposicao_do_dia = reposicao_do_dia.where(:reposicao => true)

#    reposicao_do_dia = Presenca.joins(:aluno).where(:data => Date.today).where(:reposicao => true)

    @agenda_do_dia = []

    agenda_do_dia.each do |a|
      @agenda_do_dia << a
    end

    reposicao_do_dia.each do |r|
      @agenda_do_dia << r
    end

    @agenda_do_dia = @agenda_do_dia.group_by{ |a| a.dia_da_semana.to_i }

    @agenda_do_dia.each do |k, agenda|
      agenda.sort! {|x,y| (x.horario[0..1].to_i * 3600 + x.horario[1..2].to_i * 60) <=> (y.horario[0..1].to_i * 3600 + y.horario[1..2].to_i * 60)}
    end

=begin    temp = []
    agenda = []
    @agenda_do_dia.each do |a|
      if not temp.blank? and temp.last.dia_da_semana.to_i != a.dia_da_semana.to_i
        agenda << temp
        temp = []
      end
      temp << a
    end
    agenda << temp
    @agenda_do_dia = agenda
    @agenda_do_dia.sort! {|x,y| (x.horario[0..1].to_i * 3600 + x.horario[1..2].to_i * 60) <=> (y.horario[0..1].to_i * 3600 + y.horario[1..2].to_i * 60)}
=end
  end

end
