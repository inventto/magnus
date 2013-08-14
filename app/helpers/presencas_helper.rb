#coding: utf-8
module PresencasHelper
  def status_column(record, column)
    presenca = record
    aluno_id = record.pessoa_id
    dia_atual = (Rails.env.development?) ? Time.now : Time.now + Time.zone.utc_offset
    hint = []
    retorno = ""
    if presenca.presenca
      retorno = "<img src='/assets/presenca.png' title='Presença Registrada' />"
      hint << "P"
      if presenca.realocacao
        retorno << "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
        hint << "R"
      elsif presenca.aula_extra
        retorno << "<img class='realocacao' src='/assets/aula_extra.png' title='Aula Extra' />"
        hint << "E"
      end
      if presenca.fora_de_horario
        retorno = "<img src='/assets/fora_de_horario.png' title='Fora de Horario' />"
      end
    else
      if presenca.justificativa_de_falta.nil?
        retorno = "<img src='/assets/falta_sem_justif.png' title='Falta Sem Justificativa' />"
        hint << "F"
      elsif presenca.tem_direito_a_reposicao?
        retorno = "<img src='/assets/falta_justif_com_direito_a_reposicao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
        hint << "CD"
      else
        retorno = "<img src='/assets/falta_justif_sem_direito_a_reposicao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
        hint << "SD"
      end
      if presenca.realocacao
        hora_atual = get_segundos(dia_atual)
        hora_presenca = get_segundos(presenca.horario)
        if (((presenca.data == dia_atual.to_date) and not (hora_atual > (hora_presenca + 300))) or (presenca.data > dia_atual.to_date))
          retorno = "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
          hint << "R"
        else
          retorno << "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
          hint << "R"
        end
      end
    end
    hint = "<div class='hint'>#{hint.uniq.join('')}</div>"
    (retorno << hint).html_safe
  end

  def get_title_realocacao(aluno_id, data_atual, presenca)
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
            if get_segundos(presenca.horario) > get_segundos(p.horario) # adiantamento
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

  def get_segundos(hour)
    if hour.instance_of?(Time)
      return hour.seconds_since_midnight
    else
      return Time.strptime(hour, "%H:%M").seconds_since_midnight
    end
  end

  def pessoa_column(record, column)
    nome = record.pessoa.nome
    fones = []
    if not record.pessoa.telefones.nil?
      record.pessoa.telefones.each do |telefone|
        fones << telefone.label
      end
    end
    fones = "<br/><div class='fones'>#{fones.join("<br/>")}</div>"
    raw(nome + fones)
  end

  def justificativa_de_falta_search_column(record, html_options)
    selected = html_options.delete :value

    select_options = ["Não Possui", "Possui"]

    options = { :selected => selected,
                :include_blank => as_(:_select_)}
    select(:record, :justificativa_de_falta, select_options, options, html_options)
  end
end
