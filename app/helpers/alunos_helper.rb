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
    script = "<script type='text/javascript'>
                 $(document).ready(function() {
                    $('#record_horario').mask('99:99');
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
              </script>"

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
      conteudo << "<td>" << ( (presenca.reposicao) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.fora_de_horario) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.justificativa_de_falta.nil?) ? get_link(presenca) : presenca.justificativa_de_falta.descricao ) << "</td>"
      conteudo << "</tr>"
      even_record = !even_record
    end

    table = "<div id='presencas_table' class='active-scaffold'>
       <table>
         <thead>
           <tr>
             <th>Data</th>
             <th>Horário</th>
             <th>Pontualidade</th>
             <th>Presença</th>
             <th>Reposição</th>
             <th>Fora de Horário</th>
             <th>Justificativa de Falta</th>
           </tr>
         </thead>
         <tbody>
           #{conteudo}
         </tdboy>
       </table>
     </div>"

    aluno_id = record.id
    hora_certa = Time.now + Time.zone.utc_offset

    proximo_horario_de_aula = get_data_e_horario(aluno_id, hora_certa)
    data = proximo_horario_de_aula["data"]

    while not Presenca.where(:aluno_id => aluno_id).where(:data => data).blank?
      proximo_horario_de_aula = get_data_e_horario(aluno_id, data)
      data = proximo_horario_de_aula["data"]
    end

    horario = proximo_horario_de_aula["horario"]

    next_class = "<br /><h4>Próxima Aula</h4>
                  <p>Data</p>
                  <p><input  class='text-input' id='data_aula' name='data' type='date' value='#{data.to_date}' /></p>
                  <p>Horário<p>
                  <p><input autocomplete='off' class='horario-input text-input' id='record_horario' maxlength='255' name='horario' size='30' type='text' value='#{horario}'><p>
                  <p>Justificativa</p>
                  <p><input autocomplete='off' class='text-input' id='justificativa_de_falta' maxlength='255' name='descricao' size='30' type='text'></p>"

    input = "<br /><input type='button' id='justificar' value='Justificar Falta' onclick='justificarFalta()' />"

    (table << next_class << input << script).html_safe
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
