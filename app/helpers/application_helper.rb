# -*- encoding : utf-8 -*-
#coding: utf-8
module ApplicationHelper
  def status_presenca horario_da_aula, dia_atual
    @hora_certa = (Time.now)

    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta ON presencas.id=presenca_id").where(:data => dia_atual)

    if horario_da_aula.instance_of? HorarioDeAula
      aluno_id = horario_da_aula.matricula.pessoa.id
      presenca = presenca.where(:pessoa_id => aluno_id).where("realocacao is null or realocacao = false")
    else # será uma instancia de Presença
      aluno_id = horario_da_aula.pessoa.id
      presenca = presenca.where(:id => horario_da_aula.id)
    end

    aniversario = get_aluno_de_aniversario(aluno_id, dia_atual)

    if horario_da_aula.instance_of? HorarioDeAula
      inativo_desde = horario_da_aula.matricula.inativo_desde
      inativo_ate = horario_da_aula.matricula.inativo_ate
      matricula_standby = !(Matricula.where('pessoa_id = ? and ? between inativo_desde and inativo_ate',  aluno_id, dia_atual).empty?)
    end

    if not presenca.blank?
      presenca = presenca[0]

      retorno = ""
      if presenca.presenca
        retorno = image_tag("presenca.png", title: 'Presença Registrada')
        if presenca.realocacao
          retorno << image_tag("realocacao.png", title: get_title_realocacao(aluno_id, dia_atual, presenca) )
        elsif presenca.aula_extra
          retorno << image_tag("aula_extra.png", title: "Aula Extra")
        end
        if presenca.fora_de_horario
          retorno = image_tag("fora_de_horario.png", title: "Fora de Horário")
        end
        retorno = (aniversario << retorno)
        #retorno = "<a href='/presencas/#{presenca.id}/edit'>" << retorno << "</a>"
        retorno = link_to(retorno.html_safe, edit_presenca_path(presenca.id))

        if matricula_standby
          retorno << image_tag("inativo.png", title: "Matrícula em estado inativo")
        end
        return retorno.html_safe
      else
        if is_feriado?(dia_atual)
          retorno = image_tag("bandeira_feriado.png", title: "Feriado")
        else
          if presenca.justificativa_de_falta.nil?
            retorno = image_tag("falta_sem_justif.png", title: "Falta sem Justificativa")
          elsif presenca.tem_direito_a_reposicao?
            retorno = image_tag("falta_justif_com_direito_a_reposicao.png", title: get_title_realocacao(aluno_id, dia_atual,presenca))
          else
            retorno = image_tag("falta_justif_sem_direito_a_reposicao.png", title: get_title_realocacao(aluno_id, dia_atual, presenca))
          end
          if presenca.realocacao
            hora_atual = get_in_seconds()
            hora_presenca = get_in_seconds(presenca.horario)

            if (((presenca.data == @hora_certa.to_date) and not (hora_atual > (hora_presenca + 300))) or (presenca.data > @hora_certa.to_date))
              retorno = image_tag("realocacao.png", title: get_title_realocacao(aluno_id, dia_atual, presenca))
            else
              retorno << image_tag("realocacao.png", title: get_title_realocacao(aluno_id, dia_atual, presenca))
            end
          end
        end
        if matricula_standby
          retorno << image_tag("inativo.png", title: "Matrícula em estado inativo")
        end
        retorno = (aniversario << retorno)
        #retorno = "<a href='/presencas/#{presenca.id}/edit'>" << retorno << "</a>"
        retorno = link_to(retorno.html_safe, edit_presenca_path(presenca.id))
        return retorno.html_safe
      end
    else
      if matricula_standby
        aniversario << image_tag("inativo.png", title: "Matrícula em estado invativo")
      end
      return aniversario.html_safe # mesmo que não haja presença deve se retornar a imagem de aniversário
    end
  end

  def is_feriado? dia_atual
    ok = false
    feriado = Feriado.where(:dia => dia_atual.day).where(:mes => dia_atual.month)
    if not feriado.blank?
      feriado = feriado[0]
      if feriado.repeticao_anual or feriado.ano == dia_atual.year
        ok = true
      end
    end
    ok
  end

  def get_title_realocacao aluno_id, dia_atual, presenca
    title = ""
    if presenca.realocacao? and not presenca.data_de_realocacao.blank?
      p = Presenca.joins(:justificativa_de_falta).where(:pessoa_id => aluno_id, :data => presenca.data_de_realocacao).where("justificativas_de_falta.descricao ilike '%adiantado%'")
      if not p.blank?
        title = "Adiantamento do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário das #{p[0].horario}"
      else
        p = Presenca.where(:pessoa_id => aluno_id, :data => presenca.data_de_realocacao)
        title = "Reposição do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário das #{p[0].horario}"
      end
    elsif not presenca.presenca? and presenca.data_de_realocacao.blank? and not presenca.justificativa_de_falta.nil?
        p = Presenca.order("id DESC").find_by_data_de_realocacao_and_pessoa_id(presenca.data, aluno_id) #em ordem descrescente pois caso haja mais de uma realocação para esse dia
        if not p.nil?
          horario = ""
          if not presenca.justificativa_de_falta.nil? and not presenca.justificativa_de_falta.descricao.nil?
            m = presenca.justificativa_de_falta.descricao.match(/\d{1,2}:\d{1,2}/)
            horario = (not m.nil?) ?  m[0] : ""
          end

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
          if presenca.tem_direito_a_reposicao?
            title = "Falta Justificada com Direito à Reposição"
          else
            title = "Falta Justificada sem Direito à Reposição"
          end
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
    nascimento = Pessoa.find(aluno_id).data_nascimento
    data_nascimento = Time.mktime(nascimento.year, nascimento.month, nascimento.day)
    aniversario = Time.mktime(Time.now.year, data_nascimento.month, nascimento.day)

    retorno = ""
    retorno << image_tag("aniversario.png", title: "Aniversário Hoje", size: "16px") if aniversario.to_date == dia.to_date
    retorno
  end

  def nao_mostrar_repetido?(agenda, dia_atual)
    aluno_id = agenda.matricula.pessoa.id

    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta ON presencas.id=presenca_id").where(:data => dia_atual)

    presenca = presenca.where(:pessoa_id => aluno_id)

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
      aluno_id = (horario.instance_of?(HorarioDeAula)) ? horario.matricula.pessoa.id : horario.pessoa.id
      if aluno_com_matricula_e_hora_de_aula_validos?(aluno_id, dia_atual, horario) # se pelo menos um aluno for válido
        exibir = true
        break
      end
    end
    exibir
  end

  def aluno_com_matricula_e_hora_de_aula_validos? aluno_id, dia_atual, horario_de_aula
    if horario_de_aula.instance_of?(Presenca)
      if horario_de_aula.data != dia_atual # para evitar que exiba as presenças que não são do dia
        return false
      end
    end
    ok = true
    mat = Matricula.where("data_inicio <= '#{dia_atual}' and (data_fim >= '#{dia_atual}' or data_fim is null)").where(:pessoa_id => aluno_id)
    if mat.blank?
      ok = false
    else
      p = Presenca.where(:pessoa_id => aluno_id, :data => dia_atual)[0]
      if p.blank? # se a presença ainda não tiver sido lançada
        hor = mat.joins(:horario_de_aula).where(:"horarios_de_aula.id" => horario_de_aula.id, :"horarios_de_aula.dia_da_semana" => dia_atual.wday)
        # se não existir horário de aula para o dia da semana tal com matricula válida, pois podem existir mais de uma matrícula para o mesmo aluno, mas somente uma válida
        if hor.blank?
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

  def mostrar_nome_para aluno, horario, data
    img = status_presenca(horario, data)

    _class = "nome_do_aluno"
    if img =~ /falta_justif/
      _class += " falta_justificada"
    end
    _class += " esta_de_aniver " if aluno.esta_de_aniversario_essa_semana?
    _class += " matricula_standby" if aluno.com_matricula_standby?(data)
    _class += " eh-realocacao" if aluno.eh_realocacao?(data, horario.horario, aluno.id)

    _space = "  "
    text_link = aluno.primeiro_nome + _space + content_tag(:span, aluno.segundo_nome) + _space + 
    content_tag(:span, aluno.segundo_nome[0], :id => "segundo_nome_hidden") + 
    content_tag(:span, img, :class =>'status_presenca')
    content_tag(:div, text_link.html_safe, :onclick => "window.location='#{pessoa_path(aluno)}'", :class => _class)
  end

  def arredonda_hora hora
    h,m = hora.split(":")
    h.to_i + (m.to_i / 30)
  end

  def mostrar_cor_professor hora,today
    h,m = hora.split(":")
      hora_final = ("%02d" % (h.to_i + 1 ))+":"+m
      ms = ("%02d" % (m.to_i + 05 ))
      hora_t = h

      professores = @pontos_do_dia.select{|registro|
        h,m = registro.hora_de_chegada.split(":")
        registro.data == today && arredonda_hora(hora) >=  arredonda_hora(registro.hora_de_chegada) &&
          (registro.hora_de_saida.nil? || hora_final <= registro.hora_de_saida)}.collect(&:pessoa)
    professores.collect do |professor|
        content_tag(:div, professor.nome[0,1], :class => 'professor-cor', :cor => professor.cor, :title => professor.nome)
    end.join("").html_safe
  end

end
