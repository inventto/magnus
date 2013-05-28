#coding: utf-8
module ApplicationHelper
  def status_presenca agenda, dia_atual
    begin
      aluno_id = agenda.matricula.aluno.id
      presenca_id = ""
    rescue
      aluno_id = agenda.aluno.id
      presenca_id = agenda.id
    end

    aniversario = get_aluno_de_aniversario(aluno_id, dia_atual)

    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta ON presencas.id=presenca_id").where(:data => dia_atual)

    if presenca_id.blank?
      presenca = presenca.where(:aluno_id => aluno_id).where("reposicao is null or reposicao = false")
    else
      presenca = presenca.where(:id => presenca_id)
    end

    if not presenca.blank?
      presenca = presenca[0]
      puts "==[aluno_id #{aluno_id} - dia #{dia_atual} - "
      return aniversario.html_safe if not chk_horarios?(agenda.horario, presenca.horario)

      retorno = ""
      if presenca.presenca
        retorno = "<img src='/assets/presenca.png' title='Presença Registrada' />"
        if presenca.reposicao
          retorno << "<img src='/assets/reposicao.png' title='Reposição' />"
        end
        if presenca.fora_de_horario
          retorno = "<img src='/assets/fora_de_horario.png' title='Fora de Horario' />"
        end
        retorno = (aniversario << retorno)
        return retorno.html_safe
      else
        if presenca.justificativa_de_falta.nil?
          retorno = "<img src='/assets/falta_sem_justif.png' title='Falta Sem Justificativa' />"
        else
          retorno = "<img src='/assets/falta_justif.png' title='Falta Justificada' />"
        end
        if presenca.reposicao
          if get_in_seconds(presenca.horario) < get_in_seconds()
            retorno << "<img src='/assets/reposicao.png' title='Reposição' />"
          else
            retorno = "<img src='/assets/reposicao.png' title='Reposição' />"
          end
        end
        retorno = (aniversario << retorno)
        return retorno.html_safe
      end
    else
      return aniversario.html_safe # mesmo que não haja presença deve se retornar a imagem de aniversário
    end
  end

  def get_in_seconds(hour = "")
    if not hour.blank?
      return Time.strptime(hour, "%H:%M").seconds_since_midnight
    else
      return Time.now.seconds_since_midnight
    end
  end

  def get_aluno_de_aniversario aluno_id, dia
    nascimento = Aluno.find(aluno_id).data_nascimento
    data_nascimento = Time.mktime(nascimento.year, nascimento.month, nascimento.day)
    aniversario = Time.mktime(Time.now.year, data_nascimento.month, nascimento.day)

    retorno = ""
    retorno << "<img src='/assets/aniversario.png' title='Aniversário Hoje' width='16px' />" if aniversario.to_date == dia.to_date
    retorno
  end

  def chk_horarios?(horario_agenda, horario_presenca)
    agenda = Time.strptime(horario_agenda, "%H:%M").seconds_since_midnight
    presenca = Time.strptime(horario_presenca, "%H:%M").seconds_since_midnight

    (presenca >= (agenda - 900)) && (presenca <= (agenda + 3600))
  end

  def final_do_horario horario
    (Time.strptime(horario,"%H:%M") + 3600).strftime("%H:%M")
  end

  def exibir_aluno? aluno_id, dia_atual
     Matricula.where("data_inicio <= '#{dia_atual}' and (data_fim >= '#{dia_atual}' or data_fim is null)").find_by_aluno_id(aluno_id)
  end
end
