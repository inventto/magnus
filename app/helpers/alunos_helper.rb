#coding: utf-8
module AlunosHelper
  def foto_column(model, column)
    "<img src='#{model.foto}' height='48'>".html_safe
  end

  def id_form_column(record, column)
    "<span class='id'>#{record.id}</span>"
  end

  def codigo_de_acesso_form_column(record, column)
    script = "<script type='text/javascript'>
                 function gerarCodigoDeAcesso() {
                    var jqxhr = $.ajax({
                      url: '/gerar_codigo_de_acesso?nascimento='+$('[name=\"record[data_nascimento]\"]').val()+'&id='+$(\".id\").text()
                    });
                    jqxhr.always(function () {
                      codigo = jqxhr.responseText
                      if (codigo != '') {
                        $('[name=\"record[codigo_de_acesso]\"]').val(codigo);
                      } else {
                        var data = $('[name=\"record[data_nascimento]\"]').val();
                        data = data.replace(/\D/g, \"\"); //caso o campo data venha com apenas os caracteres da formatação do campo ( __/__/____ )
                        if (data == \"\") {
                          $('[name=\"record[data_nascimento]\"]').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                          jAlert('Para gerar o código de acesso informe a data de nascimento!', 'Atenção');
                        }
                      }
                    });
                 }
              </script>"
    script << "<input autocomplete='off' class='codigo_de_acesso-input text-input' id='record_codigo_de_acesso_#{record.id}' maxlength='255' name='record[codigo_de_acesso]' size='30' type='text' value='#{record.codigo_de_acesso}' >
     <input type='button' id='gerar_codigo_de_acesso' value='Gerar Código de Acesso' onclick='gerarCodigoDeAcesso()' />".html_safe
  end

  def telefones_column(record, column)
    raw(record.telefones.collect do |telefone|
      telefone.label
    end.join "<br/>")
  end

  def presencas_column(record, column)
    inputDisabled = "<input type='checkbox' disabled='disabled' />"
    inputEnabled = "<input type='checkbox' disabled='enabled' checked='checked' />"
    conteudo = ""
    even_record = false

    record.presencas.order("data desc").order("horario desc").limit(5).each do |presenca|
      conteudo << ( (even_record) ? "<tr class='record even-record'>" : "<tr class='record'>" )
      conteudo << "<td>" << presenca.data.strftime("%d/%m/%Y") << "</td>"
      conteudo << "<td>" << presenca.horario << "</td>"
      conteudo << "<td>" << presenca.pontualidade.to_s << "</td>"
      conteudo << "<td>" << ( (presenca.presenca) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.realocacao) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.data_de_realocacao.nil?) ? "" : presenca.data_de_realocacao.strftime("%d/%m/%Y") ) << "</td>"
      conteudo << "<td>" << ( (presenca.fora_de_horario) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.tem_direito_a_reposicao) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.justificativa_de_falta.nil?) ? get_link(presenca) : presenca.justificativa_de_falta.descricao ) << "</td>"
      conteudo << "</tr>"
      even_record = !even_record
    end

    table = get_tabela_de_presencas(conteudo)

    aluno_id = record.id
    hora_certa = Time.now + Time.zone.utc_offset

    proximo_horario_de_aula = get_data_e_horario(aluno_id, hora_certa)
    data = proximo_horario_de_aula["data"]

    while not Presenca.where(:aluno_id => aluno_id).where(:data => data).blank?
      proximo_horario_de_aula = get_data_e_horario(aluno_id, data)
      data = proximo_horario_de_aula["data"]
    end

    horario = proximo_horario_de_aula["horario"]

    # Próxima Aula
    next_class = get_next_class(data, horario, inputEnabled)

    # Reposição
    reposicao = get_reposicao(aluno_id)

    # Adiantamento
    adiantamento = get_adiantamento(data)

    (table << next_class << reposicao << adiantamento << get_script).html_safe
  end

  def get_reposicao aluno_id
    #p = Presenca.joins(:justificativa_de_falta).where(:aluno_id => aluno_id, :presenca => false, :tem_direito_a_reposicao => true).where("justificativas_de_falta.descricao <> ''").order("id DESC")
    p = Presenca.joins(:justificativa_de_falta).where(:aluno_id => aluno_id, :presenca => false, :tem_direito_a_reposicao => true).where("justificativas_de_falta.descricao <> ''").where("data NOT IN (SELECT p2.data_de_realocacao FROM presencas p2 WHERE p2.data_de_realocacao = presencas.data AND p2.aluno_id=presencas.aluno_id)").order("id DESC") # traz a última data com falta justificada e que tem direito a reposição mas que ainda não possua uma data de realocação

    (p.blank?) ? data = "" : data = p[0].data.to_date
    reposicao = "<div style='float: left; margin-right: 65px;'>
                    <br /><h4>Criar Reposição</h4>
                    <p>Data</p>
                    <p><input  class='text-input' id='data_aula_reposicao' name='data' type='date' value='' /></p>
                    <p>Horário<p>
                    <p><input autocomplete='off' class='horario-input text-input' id='record_horario_reposicao' maxlength='255' name='horario' size='30' type='text' value=''><p>
                    <p>Data da Falta</p>
                    <p><input  class='text-input' id='data_de_realocacao_reposicao' name='data' type='date' value='#{data}' /></p>
                    <br /><input type='button' id='repor' value='Gravar' onclick='gravarReposicao()' />
                  </div>"

  end

  def get_adiantamento data
    adiantamento = "<div style='float: left;'>
                    <br /><h4>Adiantar Aula</h4>
                    <p>Data</p>
                    <p><input  class='text-input' id='data_aula_adiantamento' name='data' type='date' value='' /></p>
                    <p>Horário<p>
                    <p><input autocomplete='off' class='horario-input text-input' id='record_horario_adiantamento' maxlength='255' name='horario' size='30' type='text' value=''><p>
                    <p>Data do horário a ser Adiantado</p>
                    <p><input  class='text-input' id='data_de_realocacao_adiantamento' name='data' type='date' value='#{data.to_date}' /></p>
                    <br /><input type='button' id='adiantar' value='Adiantar aula' onclick='adiantarAula()' />
                  </div>"
  end

  def get_next_class data, horario, inputEnabled
    next_class = "<div style='float: left; margin-right: 65px;'>
                    <br /><h4>Próxima Aula</h4>
                    <p>Data</p>
                    <p><input  class='text-input' id='data_aula' name='data' type='date' value='#{data.to_date}' /></p>
                    <p>Horário<p>
                    <p><input autocomplete='off' class='horario-input text-input' id='record_horario' maxlength='255' name='horario' size='30' type='text' value='#{horario}'><p>
                    <p>Justificativa</p>
                    <p><input autocomplete='off' class='text-input' id='justificativa_de_falta' maxlength='255' name='descricao' size='30' type='text'></p>
                    <p>Tem Direito à Reposição
                    #{inputEnabled}</p>
                    <br /><input type='button' id='justificar' value='Justificar Falta' onclick='justificarFalta()' />
                  </div>"
  end

  def get_tabela_de_presencas conteudo
    table = "<div id='presencas_table' class='active-scaffold'>
       <table>
         <thead>
           <tr>
             <th>Data</th>
             <th>Horário</th>
             <th>Pontualidade</th>
             <th>Presença</th>
             <th>Realocação</th>
             <th>Data da Falta ou do horário a ser Adiantado</th>
             <th>Fora de Horário</th>
             <th>Tem Direito à Reposição?</th>
             <th>Justificativa de Falta</th>
           </tr>
         </thead>
         <tbody>
           #{conteudo}
         </tdboy>
       </table>
     </div>"
  end

  def get_script
    script = "<script type='text/javascript'>
                 $(document).ready(function() {
                   $('#record_horario').mask('99:99');
                   $('#record_horario_reposicao').mask('99:99');
                   $('#record_horario_adiantamento').mask('99:99');
                   $('#justificativa_de_falta').css('width', '300px');
                   $('#record_horario').css('width', '90px');
                   $('#record_horario_reposicao').css('width', '90px');
                   $('#record_horario_adiantamento').css('width', '90px');
                 });
                 function justificarFalta() {
                    var jqxhr = $.ajax({
                      url: '/justificar_falta?aluno_id='+$('.id-view').text().trim()+'&data='+$('#data_aula').val()+'&horario='+$('#record_horario').val()+'&justificativa='+$('#justificativa_de_falta').val()
                    });
                    jqxhr.always(function () {
                      var error = jqxhr.responseText
                      if (error != '') {
                        if (error.search(/aula/i) >= 0) {
                            $('#record_horario').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        if (error.search(/justif/i) >= 0) {
                          $('#justificativa_de_falta').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        jAlert(error, 'Atenção');
                      } else {
                        window.location.href = '/alunos';
                      }
                    });
                  }
                 function gravarReposicao() {
                    var jqxhr = $.ajax({
                      url: '/gravar_reposicao?aluno_id='+$('.id-view').text().trim()+'&data='+$('#data_aula_reposicao').val()+'&horario='+$('#record_horario_reposicao').val()+'&data_de_realocacao_reposicao='+$('#data_de_realocacao_reposicao').val()
                    });
                    jqxhr.always(function () {
                      var error = jqxhr.responseText
                      if (error != '') {
                        if (error.search(/campo/i) >= 0) {
                            $('#data_aula_reposicao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        if (error.search(/aula/i) >= 0) {
                          $('#record_horario_reposicao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        if (error.search(/falta/i) >= 0) {
                          $('#data_de_realocacao_reposicao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        jAlert(error, 'Atenção');
                      } else {
                        window.location.href = '/alunos';
                      }
                    });
                 }
                 function adiantarAula() {
                    var jqxhr = $.ajax({
                      url: '/adiantar_aula?aluno_id='+$('.id-view').text().trim()+'&data='+$('#data_aula_adiantamento').val()+'&horario='+$('#record_horario_adiantamento').val()+'&data_de_realocacao_adiantamento='+$('#data_de_realocacao_adiantamento').val()
                    });
                    jqxhr.always(function () {
                      var error = jqxhr.responseText
                      if (error != '') {
                         if (error.search(/campo/i) >= 0) {
                            $('#data_aula_adiantamento').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        if (error.search(/aula/i) >= 0) {
                          $('#record_horario_adiantamento').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        if (error.search(/adiantado/i) >= 0) {
                          $('#data_de_realocacao_adiantamento').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                        }
                        jAlert(error, 'Atenção');
                      } else {
                        window.location.href = '/alunos';
                      }
                    });
                 }

              </script>"
  end

  def get_data_e_horario aluno_id, data
    data_e_horario = {}
    proximo_horario_de_aula = get_proximo_horario_de_aula(aluno_id, data)
    dia = proximo_horario_de_aula.dia_da_semana - data.wday
    data = (data + dia.day).to_date
    if dia < 0
      data = data + 7.day
    end
    data_e_horario["data"] = data
    data_e_horario["horario"] = proximo_horario_de_aula.horario
    data_e_horario
  end

  def get_proximo_horario_de_aula aluno_id, data
    horarios_de_aula = HorarioDeAula.joins(:matricula).where(:"matriculas.aluno_id" => aluno_id).order(:dia_da_semana)

    return horarios_de_aula[0] if horarios_de_aula.count == 1 #caso tenha horario de aula em somente um dia da semana

    aula_de_hoje = horarios_de_aula.find_by_dia_da_semana(data.wday)

    if not aula_de_hoje.nil? and Presenca.where(:aluno_id => aluno_id).where(:data => data.to_date).blank?
      proximo_horario_de_aula = aula_de_hoje
    elsif horarios_de_aula.last == aula_de_hoje
      proximo_horario_de_aula = horarios_de_aula.first
    else
      proximo_horario_de_aula = horarios_de_aula.where("dia_da_semana > ?", data.wday).order(:dia_da_semana).limit(1)[0]
    end

    proximo_horario_de_aula
  end

  def get_link(presenca)
    if presenca.presenca
      return ""
    else
      return "<a href='/presencas/#{presenca.id}/edit'>Justificar</a>"
    end
  end
end
