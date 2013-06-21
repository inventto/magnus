#coding: utf-8
module ApplicationHelper
  def status_presenca agenda, dia_atual
    if agenda.instance_of? HorarioDeAula
      aluno_id = agenda.matricula.aluno.id
      presenca_id = ""
    else # será uma instancia de Presença
      aluno_id = agenda.aluno.id
      presenca_id = agenda.id
    end

    aniversario = get_aluno_de_aniversario(aluno_id, dia_atual)

    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta ON presencas.id=presenca_id").where(:data => dia_atual)

    if presenca_id.blank?
      presenca = presenca.where(:aluno_id => aluno_id).where("realocacao is null or realocacao = false")
    else
      presenca = presenca.where(:id => presenca_id)
    end

    if not presenca.blank?
      presenca = presenca[0]

      retorno = ""
      if presenca.presenca
        retorno = "<img src='/assets/presenca.png' title='Presença Registrada' />"
        if presenca.realocacao
          retorno << "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
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
        if presenca.realocacao
          hora_atual = get_in_seconds()
          hora_presenca = get_in_seconds(presenca.horario)

          if (presenca.data == (Time.now + Time.zone.utc_offset).to_date) and ( (hora_atual > hora_presenca) and (hora_atual < (hora_presenca + 3600)) )
            retorno = "<img class='realocacao' src='/assets/realocacao.png' title='Reposição' />"
          else
            retorno << "<img class='realocacao' src='/assets/realocacao.png' title='Reposição' />"
          end
        end
        retorno = (aniversario << retorno)
        return retorno.html_safe
      end
    else
      return aniversario.html_safe # mesmo que não haja presença deve se retornar a imagem de aniversário
    end
  end

  def get_title_realocacao aluno_id, dia_atual, presenca
    title = ""
    if presenca.presenca? and presenca.realocacao? and not presenca.data_de_realocacao.blank? and not presenca.tem_direito_a_reposicao?
      p = Presenca.joins(:justificativa_de_falta).where(:aluno_id => aluno_id, :data => presenca.data_de_realocacao).where("justificativas_de_falta.descricao ilike '%adiantado%'")
      if not p.blank?
        title = "Adiantamento do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário #{p[0].horario}"
      end
    end
      #p = Presenca.joins(:justificativa_de_falta).where(:aluno_id => aluno_id, :data => dia_atual).where("justificativas_de_falta.descricao ilike '%adiantado%'")
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

  def nao_mostrar_repetido?(agenda, dia_atual)
    aluno_id = agenda.matricula.aluno.id

    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta ON presencas.id=presenca_id").where(:data => dia_atual)

    presenca = presenca.where(:aluno_id => aluno_id)

    if not presenca.blank?
      presenca = presenca.first
      return (presenca.fora_de_horario? or presenca.realocacao?)
    end
  end

  def final_do_horario horario
    (Time.strptime(horario,"%H:%M") + 3600).strftime("%H:%M")
  end

  def horario_possui_aluno_valido? horarios_de_aula, dia_atual
    exibir = false
    horarios_de_aula.each do |horario|
      aluno_id = horario.matricula.aluno.id rescue aluno_id = horario.aluno.id
      if aluno_com_matricula_e_hora_de_aula_validos?(aluno_id, dia_atual) # se pelo menos um aluno for válido
        exibir = true
        break
      end
    end
    exibir
  end

  def aluno_com_matricula_e_hora_de_aula_validos? aluno_id, dia_atual
    ok = true
    mat = Matricula.where("data_inicio <= '#{dia_atual}' and (data_fim >= '#{dia_atual}' or data_fim is null)").find_by_aluno_id(aluno_id)
    if mat.blank?
      ok = false
    else
      p = Presenca.where(:aluno_id => aluno_id, :data => dia_atual)[0]
      if p.blank? # se a presença ainda não tiver sido lançada
        hor = HorarioDeAula.do_aluno_pelo_dia_da_semana(aluno_id, dia_atual.wday)
        if hor.blank? # se não existir horário de aula para aquele aluno no dia da semana tal
          ok = false
        end
      else
        if p.realocacao? # caso exista presença e a mesma for reposição
          if p.data != dia_atual # e a data da reposição for diferente do dia em questão
            ok = false
          end
        end
      end
    end
    return ok
  end
end
