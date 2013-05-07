class AgendaDoDiaController < ApplicationController
  def agenda
    agenda_do_dia = HorarioDeAula.joins(:matricula).joins("INNER JOIN alunos ON matriculas.aluno_id=alunos.id").where(:"horarios_de_aula.dia_da_semana" => Time.now.wday).where("data_inicio <= current_date and (data_fim >= current_date or data_fim is null)")

    reposicao_do_dia = Presenca.joins(:aluno).where(:data => Date.today).where(:reposicao => true)

    @agenda_do_dia = []

    agenda_do_dia.each do |a|
      @agenda_do_dia << a
    end

    reposicao_do_dia.each do |r|
      @agenda_do_dia << r
    end

    @agenda_do_dia.sort! {|x,y| (x.horario[0..1].to_i * 3600 + x.horario[1..2].to_i * 60) <=> (y.horario[0..1].to_i * 3600 + y.horario[1..2].to_i * 60)}
  end
end
