#coding: utf-8
module PessoasHelper
  def foto_column(model, column)
    "<img src='#{model.foto}' height='48'>".html_safe
  end

  def id_form_column(record, column)
    "<span class='id'>#{record.id}</span>"
  end

  def codigo_de_acesso_form_column(record, column)
    script = "<script type='text/javascript'>
                 function gerarCodigoDeAcesso() {
                    eh_funcionario = ($('.e_funcionario-input').is(':checked')) ? 1 : 0;
                    var jqxhr = $.ajax({
                      url: '/gerar_codigo_de_acesso?nascimento='+$('[name=\"record[data_nascimento]\"]').val()+'&id='+$(\".id\").text()+'&eh_funcionario='+eh_funcionario
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
    if record.instance_of?(Pessoa)
      return if record.presencas.blank?

      @count_presencas = 0
      @count_aulas_extras = 0

      presencas = record.presencas

      presencas.each do |presenca|
        if presenca.presenca?
          if presenca.aula_extra?
            @count_aulas_extras += 1
          else
            @count_presencas += 1
          end
        end
      end

      count_faltas_com_direto_a_repos_permitidas = get_amout_allowed_fault(record)

      @count_faltas_sem_direito_a_reposicao = get_faltas_direito_a_reposicao(presencas, false) - count_feriados(presencas)

      @count_faltas_com_direito_a_reposicao = get_faltas_direito_a_reposicao(presencas, true)

      count_aulas_repostas = get_aulas_repostas(presencas)

      count_faltas_de_realocacoes_sem_direito_a_repos = get_faltas_de_realocacoes_sem_direito_a_reposicao(presencas)

      count_faltas_de_realocacoes_com_direito_a_repos = get_faltas_de_realocacoes_com_direito_a_reposicao(presencas)

      @count_aulas_a_repor = @count_faltas_com_direito_a_reposicao - count_aulas_repostas
      @count_aulas_a_repor -= get_amount_of_expired_classes(@count_aulas_a_repor, count_faltas_com_direto_a_repos_permitidas)
      @count_aulas_a_repor -= count_faltas_de_realocacoes_sem_direito_a_repos - count_faltas_de_realocacoes_com_direito_a_repos

      @count_aulas_realocadas = presencas.where(:realocacao => true).count

      @total_de_aulas = presencas.count

      table = get_tabela_de_estatisticas

      graph = get_grafico_pizza

      table << graph
    end
  end

  def count_feriados presencas
    count_faltas = 0
    presencas.where(:presenca => false, :tem_direito_a_reposicao => false).each do |falta|
      if is_holiday_this_day?(falta.data)
        count_faltas += 1
      end
    end
    puts "===> quantidade de faltas feriados #{count_faltas}"
    count_faltas
  end

  def is_holiday_this_day? dia_atual
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

  def get_faltas_direito_a_reposicao presencas, tem_direito_a_reposicao
    faltas = presencas.where("coalesce(presenca,'f') = 'f'")
    if tem_direito_a_reposicao
      faltas = faltas.where(:tem_direito_a_reposicao => tem_direito_a_reposicao).count
    else
      faltas = faltas.where("coalesce(tem_direito_a_reposicao, 'f') = 'f'").count
    end
    faltas
  end

  def get_faltas_de_realocacoes_com_direito_a_reposicao presencas
      faltas = presencas.where(:realocacao => true).where("coalesce(presenca, 'f') = 'f'")
      faltas = faltas.where(:tem_direito_a_reposicao => true).count
  end

  def get_faltas_de_realocacoes_sem_direito_a_reposicao presencas
      faltas = presencas.where(:realocacao => true)
      faltas = faltas.where("coalesce(presenca, 'f') = 'f'").where("coalesce(tem_direito_a_reposicao, 'f') = 'f'").count
      # faltas = faltas.where("(data_de_realocacao IN (#{sub_query}) OR data_de_realocacao is null)").count
  end

  def get_aulas_repostas presencas
      sub_query = "SELECT p2.data FROM presencas as p2"
      sub_query << " JOIN justificativas_de_falta as j ON j.presenca_id=p2.id"
      sub_query << " WHERE p2.data=presencas.data_de_realocacao AND"
      sub_query << " p2.pessoa_id=presencas.pessoa_id AND p2.presenca = 'f' AND"
      sub_query << " j.descricao <> '' AND p2.tem_direito_a_reposicao = 't'"

      repostas = presencas.where(:realocacao => true, :presenca => true)
      repostas = repostas.where("(data_de_realocacao IN (#{sub_query}) OR data_de_realocacao is null)").count
      repostas
  end

  def get_amount_of_expired_classes amount, amount_allowed_fault
    (amount > amount_allowed_fault) ? amount - amount_allowed_fault : 0
  end

  def get_amout_allowed_fault student
    valid_enrollment = Matricula.order(:id).find_all_by_pessoa_id(student.id).last # pega a última cadastrada que sempre será a válida
    weekly_frequency = HorarioDeAula.find_all_by_matricula_id(valid_enrollment.id).count
    (weekly_frequency * 4) # máximo de faltas em um mês
  end

  def get_grafico_pizza
    "<br/><div id='grafico_das_estatisticas_do_aluno' style='height: 400px; min-width: 600px'></div>
    <script type='text/javascript'>
    $(document).ready(function() {graph();});
    $(document).ajaxComplete(function(){graph();});
    function graph() {
      colors= [
        '#109415', // verde escuro
        '#8fee90', // verde claro
        '#f5e9e9',    // branco
        '#F00C0C'  // vermelho
      ];
      Highcharts.getOptions().colors = Highcharts.map(colors,
      function(color) {
        return {
          radialGradient: { cx: 0.5, cy: 0.3, r: 0.7 },
          stops: [
            [0, color],
            [1, Highcharts.Color(color).brighten(-0.3).get('rgb')]
          ]
        };
      });
      new Highcharts.Chart({
        chart: {
          renderTo: 'grafico_das_estatisticas_do_aluno',
          type: 'pizza'
        },
        title: {
          text: 'Gráfico das Estatísticas dos Treinamentos'
        },
        tooltip: {
          pointFormat: '{point.y}%'
        },
        plotOptions: {
          pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
              enabled: true,
              color: '#000',
              formatter: function() {
                return this.point.name + ': ' + this.point.y + '%';
              }
            },
            showInLegend: false
          }
        },
        series: [{
          type: 'pie',
          name: 'Estatísticas',
          data: [
            ['Presenças', #{@perc_presencas + @perc_aulas_extras}],
            ['Aulas Realocadas', #{@perc_de_aulas_realocadas}],
            ['Aulas a serem Realocadas', #{@perc_aulas_a_repor}],
            ['Faltas não Avisadas', #{@perc_faltas_sem_direito_a_reposicao}],
          ]
        }]
      });
    }
    </script>".html_safe

  end

  def get_tabela_de_estatisticas
    table = "<div id='estatisticas_table' class='active-scaffold'>
              <table>
                <thead>
                  <tr>
                    <th>Presenças</th>
                    <th>Aulas Extras</th>
                    <th>Treinamento com direito à realocação(+)</th>
                    <th>Faltas sem comunicar com antecedência e/ou expirados</th>
                    <th>Treinamentos realocados(-)</th>
                    <th>Saldo de Treinamentos para realocação(+)</th>
                    <th>Total de aulas</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td class='tip_trigger' style='background-color: green;'>
                      #{@count_presencas}
                      <span class='tip'>#{@perc_presencas = calcular_percentual(@count_presencas, @total_de_aulas)}%</span>
                    </td>
                    <td class='tip_trigger' style='background-color: lightblue;'>
                      #{@count_aulas_extras}
                      <span class='tip'>#{@perc_aulas_extras = calcular_percentual(@count_aulas_extras, @total_de_aulas)}%</span>
                    </td>
                    <td class='tip_trigger' style='background-color: yellow;'>
                      #{@count_faltas_com_direito_a_reposicao}
                      <span class='tip'>#{calcular_percentual(@count_faltas_com_direito_a_reposicao, @total_de_aulas)}%</span>
                    </td>
                    <td class='tip_trigger' style='background-color: red; color: black;'>
                      #{@count_faltas_sem_direito_a_reposicao}
                      <span class='tip'>#{@perc_faltas_sem_direito_a_reposicao = calcular_percentual(@count_faltas_sem_direito_a_reposicao, @total_de_aulas)}%</span>
                    </td>
                    <td class='tip_trigger' style='background-color: lightgreen;'>
                      #{@count_aulas_realocadas}
                      <span class='tip'>#{@perc_de_aulas_realocadas = calcular_percentual(@count_aulas_realocadas, @total_de_aulas)}%</span>
                    </td>
                    <td class='tip_trigger' style='background-color: white;'>
                      #{@count_aulas_a_repor}
                      <span class='tip'>#{@perc_aulas_a_repor = calcular_percentual(@count_aulas_a_repor, @total_de_aulas)}%</span>
                    </td>
                    <td>#{@total_de_aulas}</td>
                  </tr>
                </tbody>
              </table>
            </div>".html_safe

  end

  def pontualidade_column(record, column)
    if record.instance_of?(Pessoa) # se não ocorre erro ao carregar a página de Presenças
      return if record.e_funcionario
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

      @pontualidades = {
        :menor_que_menos_quinze => calcular_percentual(count_menor_que_menos_quinze, total_de_presencas),
        :maior_que_menos_quinze => calcular_percentual(count_maior_que_menos_quinze, total_de_presencas),
        :maior_que_menos_cinco  => calcular_percentual(count_maior_que_menos_cinco, total_de_presencas),
        :maior_que_cinco        => calcular_percentual(count_maior_que_cinco, total_de_presencas),
        :maior_que_quinze       => calcular_percentual(count_maior_que_quinze, total_de_presencas)
      }

      render :partial => "pontualidade"
    else
      return record.pontualidade
    end
  end

  def calcular_percentual quantidade, total
    if total > 0
      return ((quantidade.to_f / total) * 100).round(2)
    else
      return 0
    end
  end

  def presencas_column(record, column)
    if record.e_funcionario
      @registros_de_ponto = RegistroDePonto.where(:pessoa_id => record.id)
      @registros_de_ponto = @registros_de_ponto.where("data BETWEEN ? AND ?", Date.today.beginning_of_month, Date.today.end_of_month).order("data desc")
      render :partial => "registros_de_ponto_por_mes"
    else
    #return if record.presencas.blank? #caso seja aluno novo e sem registros de presenças
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
      conteudo << "<td>" << ( (presenca.aula_extra) ? inputEnabled : inputDisabled ) << "</td>"
      conteudo << "<td>" << ( (presenca.justificativa_de_falta.nil?) ? get_link(presenca) : (presenca.justificativa_de_falta.descricao.nil?) ? "" : presenca.justificativa_de_falta.descricao ) << "</td>"
      conteudo << "</tr>"
      even_record = !even_record
    end

    table = get_tabela_de_presencas(conteudo)

    aluno_id = record.id
    hora_certa = Time.now + Time.zone.utc_offset

    data = get_data(aluno_id, hora_certa)

    while not Presenca.where(:pessoa_id => aluno_id).where(:data => data).blank?
      data = get_data(aluno_id, data)
    end

    # Próxima Aula
    justify_next_class = get_next_class(data, inputEnabled)

    # realocacao
    realocacao = get_realocacao(aluno_id, data)

    (table << justify_next_class << realocacao << get_script).html_safe
    end
  end

  def get_realocacao aluno_id, data
    presenca = Presenca.joins(:justificativa_de_falta).where(:pessoa_id => aluno_id, :presenca => false, :tem_direito_a_reposicao => true)
    presenca = presenca.where("justificativas_de_falta.descricao <> ''")
    presenca = presenca.where("data NOT IN (SELECT p2.data_de_realocacao FROM presencas p2 WHERE p2.data_de_realocacao = presencas.data AND p2.pessoa_id=presencas.pessoa_id)").order("id")

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
             <th>Aula Extra?</th>
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
                  var dataDaFalta = $('#data_da_falta').val();
                  var dataDaFaltaFim = $('#data_da_falta_fim').val();
                  dataInicio = dataDaFalta.split('-');
                  dataFim = dataDaFaltaFim.split('-');
                  dataInicio = new Date(dataInicio[0], dataInicio[1], dataInicio[2]);
                  dataFim = new Date(dataFim[0], dataFim[1], dataFim[2]);
                  if (dataDaFaltaFim == '' || dataInicio < dataFim) {
                    hoje = new Date();
                    dataDaquiSeisMeses = new Date(hoje.getUTCFullYear(), (hoje.getUTCMonth() + 6), hoje.getUTCDate());
                    if (dataDaFaltaFim == '' || dataFim <= dataDaquiSeisMeses) {
                      var jqxhr = $.ajax({
                        url: '/justificar_falta?aluno_id='+$('.id-view').text().trim()+'&data_da_falta='+dataDaFalta+'&data_da_falta_fim='+dataDaFaltaFim+'&justificativa='+$('#justificativa_de_falta').val()
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
                           window.location.href = '/pessoas';
                        }
                      });
                    } else {
                      $('#data_da_falta_fim').css({'border-color': 'rgba(255, 0, 0, 0.8)', '-webkit-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', '-moz-box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)', 'box-shadow': 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(255, 0, 0, 0.6)'});
                      jAlert('<strong>Data Final</strong> deve ser no máximo até o dia ' + dataDaquiSeisMeses.toLocaleDateString(),'Atenção');
                    }
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
                        window.location.href = '/pessoas';
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
                       if ((data_sugerida == '') || (data_sugerida != '' && data_aula >= data_sug)) {
                         #{get_ajax_request_gravar_reposicao}
                       } else {
                         #{set_css_to_date_fields_realocacao}
                         jAlert('<strong>Data</strong> deve ser maior ou igual a Data a Repor', 'Atenção');
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
    if dia <= 0
      data = data + 7.day
    end
    data
  end

  def get_proximo_horario_de_aula aluno_id, data
    horarios_de_aula = HorarioDeAula.joins(:matricula).where(:"matriculas.pessoa_id" => aluno_id).order(:dia_da_semana)

    return horarios_de_aula[0] if horarios_de_aula.count == 1 #caso tenha horario de aula em somente um dia da semana

    aula_de_hoje = horarios_de_aula.find_by_dia_da_semana(data.wday)

    if not aula_de_hoje.nil? and Presenca.where(:pessoa_id => aluno_id).where(:data => data.to_date).blank?
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

  def calcula_horas_trabalhadas hora_de_chegada, hora_de_saida
    unless hora_de_saida.blank?
      hora_de_chegada = txt_to_seg hora_de_chegada
      hora_de_saida = txt_to_seg hora_de_saida
      return hora_de_saida - hora_de_chegada
    else
      return 0
    end
  end

  def txt_to_seg hour
    Time.strptime(hour, "%H:%M").seconds_since_midnight
  end

  def seconds_to_txt seconds
   hours = seconds / 3600
   min = (seconds % 3600) / 60
   "#{hours.to_i.to_s.rjust(2, '0')}:#{min.to_i.to_s.rjust(2, '0')}"
  end
end
