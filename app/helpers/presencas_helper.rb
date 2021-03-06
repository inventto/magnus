# -*- encoding : utf-8 -*-
#encoding: utf-8
module PresencasHelper
  def status_column(record, column)
    presenca = record
    aluno_id = record.pessoa_id
    dia_atual = (Rails.env.development?) ? Time.now : Time.now
    hint = []
    retorno = ""

    matricula_standby = Matricula.where('pessoa_id = ? and ? between inativo_desde and inativo_ate', aluno_id, presenca.data).empty?

    if presenca.presenca
      retorno = "<img src='/assets/presenca.png' title='Presença Registrada' />"
      hint << "P"
      if presenca.realocacao
        if presenca.conciliamento_para.nil?
          retorno << "<img class='realocacao' src='/assets/aula_realocacao_em_aberto.png' title='Aula de realocação em aberto' />"
        else
          retorno << "<img class='realocacao' src='/assets/realocacao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
        end
        hint << "R"
      elsif presenca.aula_extra
        if (presenca.conciliamento_para.de_id.nil?)
          retorno << "<img class='realocacao' src='/assets/aula_extra_em_aberto.png' title='Aula Extra em Aberto' />"
        else
          retorno << "<img class='realocacao' src='/assets/aula_extra.png' title='Aula Extra' />"
        end
        hint << "E"
      end
      if presenca.fora_de_horario
        retorno = "<img src='/assets/fora_de_horario.png' title='Fora de Horario' />"
      end
    else
      if is_holiday?(presenca.data)
        retorno = "<img src='/assets/bandeira_feriado.png' title='Feriado' />"
      else
        if presenca.justificativa_de_falta.nil?
          retorno = "<img src='/assets/falta_sem_justif.png' title='Falta Sem Justificativa' />"
          hint << "F"
          if presenca.expirada
            retorno << "<img src='/assets/expirada.png' title='Direito a reposição expirado' width='16px'/>"
            hint << "Ex"
          end
        elsif presenca.tem_direito_a_reposicao?
          retorno = "<img src='/assets/falta_justif_com_direito_a_reposicao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
          hint << "CD"
          if presenca.expirada
            retorno << "<img src='/assets/expirada.png' title='Direito a reposição expirado' width='16px' />"
            hint << "Ex"
          end
        else
          retorno = "<img src='/assets/falta_justif_sem_direito_a_reposicao.png' title='#{get_title_realocacao(aluno_id, dia_atual, presenca)}' />"
          hint << "SD"
          if presenca.expirada
            retorno << "<img src='/assets/expirada.png' title='Direito a reposição expirado' width='16px'/>"
            hint << "Ex"
          end
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
    end
    if not matricula_standby
      retorno << "<img src='/assets/inativo.png' title='Matrícula em estado inativo'/>"
      hint << "ST"
    end
    hint = "<div class='hint'>#{hint.uniq.join('')}</div>"
    data_de = ""
    if presenca.conciliamento_de
      data_de << ",de:"<< presenca.conciliamento_de.para.data.strftime("%d/%m/%Y") if presenca.conciliamento_de.para
      data_de << "(" << presenca.conciliamento_de.conciliamento_condition_type << ")" if presenca.conciliamento_de.para
    end

    if presenca.conciliamento_para && !presenca.conciliamento_para.de.nil?
      data_de << ",para:" << presenca.conciliamento_para.de.data.strftime("%d/%m/%Y")
      data_de << "(" << presenca.conciliamento_para.conciliamento_condition_type << ")"
    end
    
    (retorno << hint << data_de).html_safe #(retorno << hint).html_safe
  end

  def is_holiday? dia_atual
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

  def get_title_realocacao(aluno_id, data_atual, presenca)
    title = ""
    if presenca.realocacao? and not presenca.data_de_realocacao.blank?
      p = Presenca.joins(:justificativa_de_falta).where(:pessoa_id => aluno_id, :data => presenca.data_de_realocacao).where("justificativas_de_falta.descricao ilike '%adiantado%'")
      if not p.blank?
        title = "Adiantamento do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário das #{p[0].horario}"
      else
        begin
          p = Presenca.where(:pessoa_id => aluno_id, :data => presenca.data_de_realocacao)
          title = "Reposição do dia #{presenca.data_de_realocacao.strftime("%d/%m/%Y")}, horário das #{p[0].horario}"
        rescue
          title = "ERRO! sem registro de presença na data realocada."
        end
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

  def pessoa_column(record, column)
    link_to(h(record.pessoa.nome), :action => :show, :controller => 'pessoas', :id => record.pessoa.id)
  end 

  def justificativa_de_falta_search_column(record, html_options)
    selected = html_options.delete :value

    select_options = ["Não Possui", "Possui"]

    options = { :selected => selected,
                :include_blank => as_(:_select_)}
    select(:record, :justificativa_de_falta, select_options, options, html_options)
  end

  def justificativa_de_falta_column(record, column)
    if record.justificativa_de_falta
      descricao = record.justificativa_de_falta.descricao
      data = record.justificativa_de_falta.data
      hora = record.justificativa_de_falta.hora
      if descricao and data and hora
        link_justificativa = link_to("#{descricao} #{data.strftime("%d/%m/%Y")} #{hora}", edit_justificativa_de_falta_path(record.justificativa_de_falta.id), action: "edit", class:"justificativa_de_falta edit as_action", id: "as_presencas-justificativas_de_falta-edit-justificativa_de_falta-#{record.justificativa_de_falta.id}-#{record.id}-link" )
      elsif descricao and hora
        link_justificativa = link_to("#{descricao} #{hora}", edit_justificativa_de_falta_path(record.justificativa_de_falta.id), action: "edit", class:"justificativa_de_falta edit as_action", id: "as_presencas-justificativas_de_falta-edit-justificativa_de_falta-#{record.justificativa_de_falta.id}-#{record.id}-link" )
      elsif descricao and data
        link_justificativa = link_to("#{descricao} #{data.strftime('%d/%m/%Y')}", edit_justificativa_de_falta_path(record.justificativa_de_falta.id), action: "edit", class:"justificativa_de_falta edit as_action", id: "as_presencas-justificativas_de_falta-edit-justificativa_de_falta-#{record.justificativa_de_falta.id}-#{record.id}-link" )
      else
        link_justificativa = link_to("#{descricao}", edit_justificativa_de_falta_path(record.justificativa_de_falta.id), action: "edit", class:"justificativa_de_falta edit as_action", id: "as_presencas-justificativas_de_falta-edit-justificativa_de_falta-#{record.justificativa_de_falta.id}-#{record.id}-link" )
      end
    else
      link_justificativa = link_to("Criar novo", new_justificativa_de_falta_path(), action: "new", class: "justificativa_de_falta new as_action", id: "as_presencas-justificativas_de_falta-new-justificativa_de_falta-#{record.id}-link")
    end
    raw(link_justificativa)
  end
end
