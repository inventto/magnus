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

  def estatisticas_column(record, column)
    if record.instance_of?(Aluno)
      count_presencas = 0
      count_faltas_justificadas = 0
      count_faltas_sem_justificativa = 0
      count_adiantamentos = 0
      count_presencas_fora_de_horario = 0

      record.presencas.each do |presenca|
        if presenca.presenca?
          if presenca.fora_de_horario?
            count_presencas_fora_de_horario += 1
          else
            count_presencas += 1
          end
        elsif presenca.justificativa_de_falta.nil?
          count_faltas_sem_justificativa += 1
        else
          count_faltas_justificadas += 1
        end
      end

      sub_query =  "SELECT p2.data FROM presencas p2 JOIN justificativas_de_falta j ON j.presenca_id=p2.id WHERE p2.data=presencas.data_de_realocacao "
      sub_query << "AND (tem_direito_a_reposicao = false or tem_direito_a_reposicao is null) "
      sub_query << "AND ( ((cast(substr(p2.horario, 1, 2) as int4) * 3600) + (cast(substr(p2.horario, 4, 2) as int4) * 60)) > "
      sub_query << "((cast(substr(presencas.horario, 1, 2) as int4) * 3600) + (cast(substr(presencas.horario, 4, 2)as int4) * 60)) )"
      sub_query << "AND presencas.aluno_id=p2.aluno_id"

      count_adiantamentos = record.presencas.where(:realocacao => true).where("data_de_realocacao is not null")
      count_adiantamentos = count_adiantamentos.where("data_de_realocacao IN (#{sub_query}) AND (presencas.data <= presencas.data_de_realocacao)").count

      hoje = (Time.now + Time.zone.utc_offset).to_date

      count_faltas_justificadas_com_direito_a_reposicao = record.presencas.where("data BETWEEN ? AND ?", 2.month.ago, hoje).where(:presenca => false, :tem_direito_a_reposicao => true).count

      sub_query = "SELECT p2.data FROM presencas as p2 JOIN justificativas_de_falta as j ON j.presenca_id=p2.id WHERE p2.data=presencas.data_de_realocacao"
      sub_query << " AND p2.aluno_id=presencas.aluno_id AND p2.presenca = 'f' AND j.descricao <> '' AND p2.tem_direito_a_reposicao = 't'"

      count_aulas_repostas = record.presencas.where("data BETWEEN ? AND ?", 2.month.ago, hoje).where(:realocacao => true, :presenca => true)
      count_aulas_repostas = count_aulas_repostas.where("data_de_realocacao IN (#{sub_query})").count

      count_aulas_a_repor = count_faltas_justificadas_com_direito_a_reposicao - count_aulas_repostas

      total_de_aulas = record.presencas.count

      table = "<div id='estatisticas_table' class='active-scaffold'>
                 <table>
                   <thead>
                     <tr>
                       <th>Presenças</th>
                       <th>Presenças Fora de Horário</th>
                       <th>Faltas Justificadas</th>
                       <th>Faltas Sem Justificativa</th>
                       <th>Tem direito à Reposição</th>
                       <th>Aulas realocadas</th>
                       <th>Aulas a repor</th>
                       <th>Total de aulas</th>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <td class='tip_trigger'>
                         #{count_presencas}
                         <span class='tip'>#{calcular_percentual(count_presencas, total_de_aulas)}%</span>
                       </td>
                       <td class='tip_trigger'>
                         #{count_presencas_fora_de_horario}
                         <span class='tip'>#{calcular_percentual(count_presencas_fora_de_horario, total_de_aulas)}%</span>
                       </td>
                       <td class='tip_trigger'>
                         #{count_faltas_justificadas}
                         <span class='tip'>#{calcular_percentual(count_faltas_justificadas, total_de_aulas)}%</span>
                       </td>
                       <td class='tip_trigger'>
                         #{count_faltas_sem_justificativa}
                         <span class='tip'>#{calcular_percentual(count_faltas_sem_justificativa, total_de_aulas)}%</span>
                       </td>
                       <td class='tip_trigger'>
                         #{reposicoes = (count_aulas_repostas + count_aulas_a_repor)}
                         <span class='tip'>#{calcular_percentual(reposicoes, total_de_aulas)}%</span>
                       </td>
                       <td class='tip_trigger'>
                         #{(reposicoes = count_aulas_repostas + count_adiantamentos)}
                         <span class='tip'>
                           <p>Aulas repostas: #{count_aulas_repostas}</p>
                           <p>Aulas adiantadas: #{count_adiantamentos}</p>
                           #{calcular_percentual(reposicoes, total_de_aulas)}%
                         </span>
                       </td>
                       <td class='tip_trigger'>
                         #{count_aulas_a_repor}
                         <span class='tip'>#{calcular_percentual(count_aulas_a_repor, total_de_aulas)}%</span>
                       </td>
                       <td>#{total_de_aulas}</td>
                     </tr>
                   </tbody>
                 </table>
               </div>".html_safe

    end
  end

  def pontualidade_column(record, column)
    if record.instance_of?(Aluno) # se não ocorre erro ao carregar a página de Presenças
      presencas = record.presencas.where(:presenca => true)
      total_de_presencas = presencas.count

      count_maior_que_quinze = 0
      count_maior_que_cinco = 0
      count_maior_que_menos_cinco = 0
      count_maior_que_menos_quinze = 0
      count_menor_que_menos_quinze = 0

      presencas.each do |presenca|
          pontualidade = (presenca.pontualidade.nil?) ? 0 : presenca.pontualidade

          if pontualidade > 15
            count_maior_que_quinze += 1
          elsif pontualidade > 4
            count_maior_que_cinco += 1
          elsif pontualidade > -5
            count_maior_que_menos_cinco += 1
          elsif pontualidade > -15
            count_maior_que_menos_quinze += 1
          else # menor que -15
            count_menor_que_menos_quinze += 1
          end
      end

      table = "<div id='pontualidade_table' class='active-scaffold'>
                 <table>
                   <thead>
                     <tr>
                       <th>Intervalo de Pontualidade</th>
                       <th>Percentual</th>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <td>-15</td>
                       <td class='tip_trigger'>
                         #{calcular_percentual(count_menor_que_menos_quinze, total_de_presencas)}%
                         <span class='tip'>Percentual de Atraso maior que 15 minutos.</span>
                       </td>
                     </tr>
                     <tr>
                       <td>-5 a -15</td>
                       <td class='tip_trigger'>
                         #{calcular_percentual(count_maior_que_menos_quinze, total_de_presencas)}%
                         <span class='tip'>Percentual de Atraso entre 5 e 15 minutos.</span>
                       </td>
                     </tr>
                     <tr>
                       <td>-5 a 5</td>
                       <td class='tip_trigger'>
                         #{calcular_percentual(count_maior_que_menos_cinco, total_de_presencas)}%
                         <span class='tip'>Percentual do intervalo entre 4 minutos de Atraso e 4 minutos Adiantado.</span>
                       </td>
                     </tr>
                     <tr>
                       <td>5 a 15</td>
                       <td class='tip_trigger'>
                         #{calcular_percentual(count_maior_que_cinco, total_de_presencas)}%
                         <span class='tip'>Percentual de Adiantamento entre 5 e 15 minutos.</span>
                       </td>
                     </tr>
                     <tr>
                       <td>15</td>
                       <td class='tip_trigger'>
                         #{calcular_percentual(count_maior_que_quinze, total_de_presencas)}%
                         <span class='tip'>Percentual de Adiantamento maior que 15 minutos.</span>
                       </td>
                     </tr>
                   </tdboy>
                 </table>
               </div>".html_safe
               script = "<script type='text/javascript'>
                           $(document).ready(function(){
                             tooltips();
                           });
                         </script>".html_safe

      return (table << script)
    else
      return record.pontualidade
    end
  end

  def calcular_percentual quantidade, total
    ((quantidade.to_f / total) * 100).round(2)
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
      conteudo << "<td>" << ( (presenca.justificativa_de_falta.nil?) ? get_link(presenca) : (presenca.justificativa_de_falta.descricao.nil?) ? "" : presenca.justificativa_de_falta.descricao ) << "</td>"
      conteudo << "</tr>"
      even_record = !even_record
    end

    table = get_tabela_de_presencas(conteudo)

    aluno_id = record.id
    hora_certa = Time.now + Time.zone.utc_offset

    data = get_data(aluno_id, hora_certa)

    while not Presenca.where(:aluno_id => aluno_id).where(:data => data).blank?
      data = get_data(aluno_id, data)
    end

    # Próxima Aula
    justify_next_class = get_next_class(data, inputEnabled)

    # realocacao
    realocacao = get_realocacao(aluno_id, data)

    (table << justify_next_class << realocacao << get_script).html_safe
  end

  def get_realocacao aluno_id, data
    presenca = Presenca.joins(:justificativa_de_falta).where(:aluno_id => aluno_id, :presenca => false, :tem_direito_a_reposicao => true)
    presenca = presenca.where("justificativas_de_falta.descricao <> ''")
    presenca = presenca.where("data NOT IN (SELECT p2.data_de_realocacao FROM presencas p2 WHERE p2.data_de_realocacao = presencas.data AND p2.aluno_id=presencas.aluno_id)").order("id")

    data_reposicao = (presenca.blank?) ? "" : presenca.first.data.to_date

    realocacao = "<div id='gerar_realocacao'>
                    <br /><h4>Gerar Reposição/Adiantamento</h4>
                    <p>Data</p>
                    <p><input  class='text-input' id='data_aula_realocacao' name='data' type='date' value='' /></p>
                    <p>Horário<p>
                    <p><input autocomplete='off' class='horario-input text-input' id='record_horario_realocacao' maxlength='255' name='horario' size='30' type='text' value=''><p>
                    <p>Data da Falta/Horário a ser Adiantado</p>
                    <p><input  class='text-input' id='data_de_realocacao' name='data' type='date' value='#{data}' /></p>
                    <p>Sugerir Data para:</p>
                    <p>
                      <input type='radio' id='radio_adiantamento' name='tipo_realocacao' onclick='sugerirData(\"#{data}\");' value='adiantamento' checked />
                      <label for='radio_adiantamento'>Adiantamento</label>
                      <input type='radio' id='radio_reposicao' name='tipo_realocacao' onclick='sugerirData(\"#{data_reposicao}\");' value='reposicao' />
                      <label for='radio_reposicao'>Reposição</label>
                    </p>
                    <br />
                    <input type='button' id='repor' value='Gerar' onclick='gravarRealocacao();' />
                  </div>"
  end

  def get_next_class data, inputEnabled
    next_class = "<div id='justify_next_class'>
                    <br /><h4>Justificar Próxima Aula</h4>
                    <p>
                      Data
                      <span style='margin-left: 107px;'>Data Final</span>
                    </p>
                    <input class='text-input' id='data_da_falta' name='data' type='date' value='#{data.to_date}' />
                    <input class='text-input' id='data_da_falta_fim' name='data_fim' type='date' />
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

  def get_function_justificar_falta
    function = "function justificarFalta() {
                  var data_da_falta = $('#data_da_falta').val();
                  var data_da_falta_fim = $('#data_da_falta_fim').val();
                  data_inicio = data_da_falta.split('-');
                  data_fim = data_da_falta_fim.split('-');
                  data_inicio = new Date(data_inicio[0], data_inicio[1], data_inicio[2]);
                  data_fim = new Date(data_fim[0], data_fim[1], data_fim[2]);
                  if (data_da_falta_fim == '' || data_inicio < data_fim) {
                    var jqxhr = $.ajax({
                      url: '/justificar_falta?aluno_id='+$('.id-view').text().trim()+'&data_da_falta='+data_da_falta+'&data_da_falta_fim='+data_da_falta_fim+'&justificativa='+$('#justificativa_de_falta').val()
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
                  } else if (data_da_falta_fim != '') {
                    $('#data_da_falta_fim').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                    jAlert('<strong>Data Final</strong> deve ser maior que a <strong>Data</strong>!','Atenção');
                  }
                }"

  end

  def get_response_of_ajax_request
    response_ajax ="jqxhr.always(function () {
                      var error = jqxhr.responseText
                      if (error != '') {
                        if (error.search(/campo/i) >= 0) {
                          $('#data_aula_realocacao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                         }
                         if (error.search(/aula/i) >= 0) {
                           $('#record_horario_realocacao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                         }
                         if ((error.search(/adiantado/i) >= 0) || (error.search(/falta/i) >= 0) || (error.search(/cadastrado/i) >= 0)) {
                           $('#data_de_realocacao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                         }
                         jAlert(error, 'Atenção');
                      } else {
                        window.location.href = '/alunos';
                      }
                    });"

  end

  def get_ajax_request_gravar_adiantamento
    adiantamento = "var jqxhr = $.ajax({
                      url: '/gravar_realocacao?aluno_id='+$('.id-view').text().trim()+'&data='+data+'&horario='+$('#record_horario_realocacao').val()+'&data_de_realocacao='+data_sugerida+'&tipo_realocacao=A'
                    });
                    #{get_response_of_ajax_request}"

  end

  def get_ajax_request_gravar_reposicao
    reposicao = "var jqxhr = $.ajax({
                   url: '/gravar_realocacao?aluno_id='+$('.id-view').text().trim()+'&data='+data+'&horario='+$('#record_horario_realocacao').val()+'&data_de_realocacao='+data_sugerida+'&tipo_realocacao=R'
                 });
                 #{get_response_of_ajax_request}"

  end

  def set_css_to_date_fields_realocacao
    validations = "$('#data_aula_realocacao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                   $('#data_de_realocacao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});"

  end

  def get_function_gravar_realocacao
    realocacao= "function gravarRealocacao() {
                   var data = $('#data_aula_realocacao').val();
                   if (data != '') {
                     var data_sugerida = $('#data_de_realocacao').val();
                     var data_sug = data_sugerida.split('-');
                     data_sug = new Date(data_sug[0], data_sug[1], data_sug[2]);

                     var data_aula = data.split('-');
                     data_aula = new Date(data_aula[0], data_aula[1], data_aula[2]);

                     var radios = $('[name=\"tipo_realocacao\"]');
                     if (radios[0].checked) { // adiantamento
                       if (data_aula <= data_sug) {
                         #{get_ajax_request_gravar_adiantamento}
                       } else {
                         #{set_css_to_date_fields_realocacao}
                         jAlert('<strong>Data</strong> deve ser menor ou igual a Data do Horário a ser Adiantado', 'Atenção');
                       }
                     } else {                 // reposição
                       if (data_aula >= data_sug) {
                         #{get_ajax_request_gravar_reposicao}
                       } else if(data_sugerida == '') {
                         #{set_css_to_date_fields_realocacao}
                         jAlert('Não existe Falta Justificada com Direito à Reposição para Repor!', 'Atenção');
                       } else {
                         #{set_css_to_date_fields_realocacao}
                         jAlert('<strong>Data</strong> deve ser maior ou igual a Data do Horário a ser Adiantado', 'Atenção');
                       }
                     }
                   } else {
                     $('#data_aula_realocacao').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                     jAlert('Campo <strong>Data</strong> deve ser preenchido!', 'Atenção');
                   }
                 }"

  end

  def get_script
    script = "<script type='text/javascript'>
                 $(document).ready(function() {
                   $('#record_horario').mask('99:99');
                   $('#record_horario_realocacao').mask('99:99');
                   $('#justificativa_de_falta').css('width', '300px');
                   $('#record_horario_realocacao').css('width', '90px');
                 });

                 #{get_function_justificar_falta}

                 #{get_function_gravar_realocacao}

                 function sugerirData(data) {
                   var data_sugerida = $('#data_de_realocacao').val(data);
                   var radios = $('[name=\"tipo_realocacao\"]');
                   if (data_sugerida.val() == '' && radios[1].checked) {
                     jAlert('<strong>Não exisite Aula a Repor!</strong>', 'Atenção');
                   }
                 }
              </script>"
  end

  def get_data aluno_id, data
    proximo_horario_de_aula = get_proximo_horario_de_aula(aluno_id, data)
    dia = proximo_horario_de_aula.dia_da_semana - data.wday
    data = (data + dia.day).to_date
    if dia < 0
      data = data + 7.day
    end
    data
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
      if proximo_horario_de_aula.nil?
        proximo_horario_de_aula = horarios_de_aula.where("dia_da_semana < ?", data.wday).order(:dia_da_semana).limit(1)[0]
      end
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
