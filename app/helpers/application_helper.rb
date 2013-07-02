#coding: utf-8
module ApplicationHelper
  def status_presenca agenda, dia_atual
    @hora_certa = (Time.now + Time.zone.utc_offset)

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
          retorno = "<img src='/assets/falta_justif.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
        end
        if presenca.realocacao
          hora_atual = get_in_seconds()
          hora_presenca = get_in_seconds(presenca.horario)

          if (presenca.data == @hora_certa.to_date) and not (hora_atual > (hora_presenca + 300)) #(((hora_atual > hora_presenca) and (hora_atual < (hora_presenca + 3600))) or (hora_atual < hora_presenca))
            retorno = "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
          else
            retorno << "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
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
    if presenca.realocacao? and not presenca.data_de_realocacao.blank? and not presenca.tem_direito_a_reposicao?
      p = Presenca.joins(:justificativa_de_falta).where(:aluno_id => aluno_id, :data => presenca.data_de_realocacao).where("justificativas_de_falta.descricao ilike '%adiantado%'")
      if not p.blank?
        title = "Adiantamento do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário das #{p[0].horario}"
      else
        p = Presenca.where(:aluno_id => aluno_id, :data => presenca.data_de_realocacao)
        title = "Reposição do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário das #{p[0].horario}"
      end
    elsif not presenca.presenca? and presenca.data_de_realocacao.blank? and not presenca.justificativa_de_falta.nil?
        p = Presenca.order("id DESC").find_by_data_de_realocacao_and_aluno_id(presenca.data, aluno_id) #em ordem descrescente pois caso haja mais de uma realocação para esse dia
        if not p.nil?
          m = presenca.justificativa_de_falta.descricao.match(/\d{1,2}:\d{1,2}/)
          (not m.nil?) ? horario = m[0] : ""

          if presenca.data == p.data # ainda pode ser reposição ou adiantamento, depende do horario
            if get_in_seconds(presenca.horario) > get_in_seconds(p.horario) # adiantamento
              title = "Falta Justificada com Adiantamento para o dia #{presenca.data.strftime("%d/%m/%Y")} às #{horario}"
            else # reposicao
              title = "Falta Justificada com Reposição Agendada para o dia #{p.data.strftime("%d/%m/%Y")} às #{p.horario}"
            end
          elsif presenca.data > p.data # adiantamento
              title = "Falta Justificada com Adiantamento para o dia #{p.data.strftime("%d/%m/%Y")} às #{p.horario}"
          else # reposicao
              title = "Falta Justificada com Reposição Agendada para o dia #{p.data.strftime("%d/%m/%Y")} às #{p.horario}"
          end
        else # se houve a falta justificada mas ainda não foi criada a reposição
          title = "Falta Justificada"
        end
    else
      if presenca.data_de_realocacao.nil?
        title = "Reposição"
      else
        title = "Reposição Referente à Falta do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}"
      end
    end
    title
  end

  def get_in_seconds(hour = "")
    if not hour.blank?
      return Time.strptime(hour, "%H:%M").seconds_since_midnight
    else
      return @hora_certa.seconds_since_midnight #Time.now.seconds_since_midnight
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
      return ( (presenca.fora_de_horario? or presenca.realocacao?) and (agenda.horario == presenca.horario) )
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
