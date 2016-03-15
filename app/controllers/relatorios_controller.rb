# -*- encoding : utf-8 -*-
#encoding: utf-8
class RelatoriosController < ApplicationController
  active_scaffold :relatorio do |conf|
    conf.label = "Relatório"
    conf.columns = [:nome, :titulos, :consulta]
    conf.columns[:consulta].form_ui = :textarea
    conf.action_links.add 'visualizar', :position => true, :type => :member, :popup => true
  end

  def visualizar
    relatorio = Relatorio.find(params[:id].to_i)
    @args = relatorio.consulta.scan(/:[^ ,%']+/)
    consulta = relatorio.consulta
    if (not @args.empty?)
      @args.each do |arg|
        if not params[arg]
          return
        end
        if (arg =~ /_int$/ or arg =~ /_like$/)
          consulta = consulta.gsub arg, params[arg]
        else
          consulta = consulta.gsub arg, "'#{params[arg]}'"
        end
      end
    end
    resultado = ActiveRecord::Base.connection.select_rows(consulta)
    retorno = "<div class='active-scaffold'>"
    if params[":data_inicial"] and params[":data_final"]
      retorno << "<div class='active-scaffold-header'><h2>#{relatorio.nome} #{params[":data_inicial"]} à #{params[":data_final"]}</h2></div>"
    else
      retorno << "<div class='active-scaffold-header'><h2>#{relatorio.nome}</h2></div>"
    end
    if relatorio.id == 2
      retorno << "<table id='tabela_porcentagem_presencas'><tr>"
    elsif relatorio.id == 6
      retorno << "<table id='tabela_quantidade_de_horarios'><tr>"
    elsif relatorio.id == 9
      retorno << "<table id='tabela_grupo_das_idades'><tr>"
    elsif relatorio.id == 10
      retorno << "<table id='tabela_grupo_das_idades_agrupados_por_sexo'><tr>"
    else
    retorno << "<table><tr>"
    end
    relatorio.titulos.split(/[,;]/).each do |titulo|
      retorno << "<th><a href='#'>#{titulo}</a></th>"
    end
    retorno << "</tr>"
    even = false
    resultado.each do |linha|
      retorno << "<tr class='record#{even ? ' even-record' : ''}'>"
      linha.each do |campo|
        retorno << "<td>#{campo}</td>"
      end
      retorno << "</tr>"
      even = !even
    end
    retorno << "</table>"
    retorno << "#{resultado.size} Encontrado(s)"
    retorno << "</div>"
    if relatorio.id == 2
      retorno << "<div id='graficos'>"
      retorno << "</div>"
      retorno << grafico_colunas
    elsif relatorio.id == 6
      retorno << "<div id='grafico_porcentagem_de_horario'></div>"
      retorno << grafico_pizza_porcentagem_por_horario
      retorno << "<div id='grafico_de_colunas_de_horas'></div>"
      retorno << grafico_de_colunas_de_horas
    elsif relatorio.id == 9 
      retorno << "<div id='grafico_de_colunas_das_idades'></div>"
      retorno << grafico_colunas_das_idades
    elsif relatorio.id == 10
      retorno << "<div id='grafico_de_colunas_das_idades_agrupado_por_sexo'></div>"
      retorno << grafico_colunas_de_alunos_agrupados_por_sexo
    end
    retorno << 
    "<style>
    .active-scaffold .record {
         text-align: center !important;
    }
    </style>"

    render :inline => retorno.html_safe, :layout => true
  end
  def grafico_de_colunas_de_horas
    "<script>
      titulos = $('#tabela_quantidade_de_horarios tr th a')
      $('#grafico_de_colunas_de_horas').highcharts({
        chart: {
            type: 'bar'
        },
        title: {
            text: 'Gráfico quantidade de horas'
        },
        xAxis: {
            categories: [titulos[0].text, titulos[3].text, titulos[6].text, titulos[9].text, titulos[12].text]
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Total de horas'
            }
        },
        legend: {
            reversed: true
        },
        plotOptions: {
            series: {
                stacking: 'normal'
            }
        },
        series: [{
            name: 'Horas',
            data: [parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(2)').text()), parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(5)').text()), 
              parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(8)').text()), parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(11)').text()),
              parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(14)').text())]
        }]
    });
    $('#grafico_de_colunas_de_horas .highcharts-series rect:nth-child(1)').css('fill','rgba(240, 12, 12, 1)');
    $('#grafico_de_colunas_de_horas .highcharts-series rect:nth-child(2)').css('fill','#fff200');
    $('#grafico_de_colunas_de_horas .highcharts-series rect:nth-child(3)').css('fill','#11c900');
    $('#grafico_de_colunas_de_horas .highcharts-series rect:nth-child(4)').css('fill','#fc8aeb');
    $('#grafico_de_colunas_de_horas .highcharts-series rect:nth-child(5)').css('fill','#2134ff');
    $('#grafico_de_colunas_de_horas .highcharts-legend-item text').remove();
    $('#grafico_de_colunas_de_horas .highcharts-legend-item rect').remove();
    </script> 
    "
  end
  
  def grafico_pizza_porcentagem_por_horario
    "<script>
    titulos = $('#tabela_quantidade_de_horarios tr th a')
  $(document).ready(function(){
      tooltips();
      quatidadeDeHorariosGraph();
    });
    $(document).ajaxComplete(function(){
      quatidadeDeHorariosGraph();
    });
    function quatidadeDeHorariosGraph() {
       colors= [
         '#F00C0C', // vermelho
         '#FFF200', // amarelo
         '#11C900', // verde
         '#fc8aeb', // lilás (roxo whatever)
         '#2134ff'  // azul
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
          renderTo: 'grafico_porcentagem_de_horario',
          type: 'pizza'
        },
        title: {
          text: 'Gráfico de horários por período'
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
            [titulos[0].text, parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(3)').text())],
            [titulos[3].text, parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(6)').text())],
            [titulos[6].text, parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(9)').text())],
            [titulos[9].text, parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(12)').text())],
            [titulos[12].text, parseInt($('#tabela_quantidade_de_horarios tr td:nth-child(15)').text())]
          ]
        }]
      });
    }
</script>
   "
  end

  def grafico_colunas
    "<script>
    ignorar_primeiras_x_colunas = 2;
    Highcharts.visualize = function(table, options) {
      options.xAxis.categories = new Array();
      options.series = [];
      $('tbody th', table).each( function(i) {
        if (i >= ignorar_primeiras_x_colunas) {
          options.series[i - ignorar_primeiras_x_colunas] = {
                // Legenda
                name: this.innerHTML,
                data: []
              };
        }
      });
      $('tr', table).each( function(i) {
        var tr = this;
        $('td', tr).each( function(j) {
          if (j == 0) {
            // valores eixo X
            options.xAxis.categories.push(this.innerHTML);
          }
          if (j >= ignorar_primeiras_x_colunas) {
            options.series[j - ignorar_primeiras_x_colunas].data.push(parseFloat(this.innerHTML));
          }
        });
      });
      var chart = new Highcharts.Chart(options);
    };
    $(document).ready(function() {
      var table = document.getElementById('tabela_porcentagem_presencas'),
      options = {
        chart: {
          renderTo: 'graficos',
          type: 'column',
          defaultSeriesType: 'column'
        },
        title: {
          text: 'Estatisticas de Faltas por dia da semana'
        },
        xAxis: {
        },
        yAxis: {
          title: {
            text: '%'
          }
        },
        tooltip: {
          formatter: function() {
            return '<b>'+ this.series.name +'</b><br/>'+
            this.y +' '+ this.x.toLowerCase();
          }
        }
      };
      Highcharts.visualize(table, options);
    });
    </script>"
  end
   
  def grafico_colunas_das_idades
    "<script>
    ignorar_primeiras_x_colunas = 1;
    Highcharts.visualize = function(table, options) {
      options.xAxis.categories = new Array();
      options.series = [];
      $('tbody th', table).each( function(i) {
         if(i > 0) {
          options.series[options.series.length] = {
                // Legenda
                name: this.innerHTML,
                data: []
              };
         }
      });
      $('tr', table).each( function(i) {
        var tr = this;
        $('td', tr).each( function(j) {
          if (j == 0) {
            // valores eixo X
            options.xAxis.categories.push(this.innerHTML);
          } else {
            console.log('inserindo as idades: ', j)
            options.series[j-1].data.push(parseInt(this.innerHTML));
            console.log(options.series)
          }
        });
      });
      var chart = new Highcharts.Chart(options);
    };
    $(document).ready(function() {
      var table = document.getElementById('tabela_grupo_das_idades'),
      options = {
        chart: {
          renderTo: 'grafico_de_colunas_das_idades',
          type: 'column',
          defaultSeriesType: 'column'
        },
        title: {
          text: 'Grupo das idades'
        },
        xAxis: {
          title: {
            text: 'Idade'
          }
        },
        yAxis: {
          title: {
            text: 'Quantidade'
          }
        },
        tooltip: {
          formatter: function() {
            return '<b>'+ this.series.name +'</b><br/>'+
            this.y +' '+ this.x.toLowerCase();
          }
        }
      };
      Highcharts.visualize(table, options);
    });
    </script>"
  end

  def grafico_colunas_de_alunos_agrupados_por_sexo
    "<script>
    ignorar_primeiras_x_colunas = 1;
    Highcharts.visualize = function(table, options) {
      options.xAxis.categories = new Array();
      options.series = [];
      $('tbody th', table).each( function(i) {
         if(i > 0) {
          options.series[options.series.length] = {
                // Legenda
                name: this.innerHTML,
                data: []
              };
         }
      });
      $('tr', table).each( function(i) {
        var tr = this;
        $('td', tr).each( function(j) {
          if (j == 0) {
            // valores eixo X
            options.xAxis.categories.push(this.innerHTML);
          } else {
            console.log('inserindo as idades: ', j)
            options.series[j-1].data.push(parseInt(this.innerHTML));
            console.log(options.series)
          }
        });
      });
      var chart = new Highcharts.Chart(options);
    };
    $(document).ready(function() {
      var table = document.getElementById('tabela_grupo_das_idades_agrupados_por_sexo'),
      options = {
        chart: {
          renderTo: 'grafico_de_colunas_das_idades_agrupado_por_sexo',
          type: 'column'
        },
        title: {
          text: 'Grupo das idades agrupados por sexo'
        },
        xAxis: {
          title: {
            text: 'Idade'
          }
        },
        yAxis: {
          title: {
            text: 'Quantidade'
          }
        },
        tooltip: {
          formatter: function() {
            return '<b>'+ this.series.name +'</b><br/>'+
            this.y +' '+ this.x.toLowerCase();
          }
        }
      };
      Highcharts.visualize(table, options);
    });
    </script>"
  end

end
