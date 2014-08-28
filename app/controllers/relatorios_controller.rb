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
    retorno << "<div class='active-scaffold-header'><h2>#{relatorio.nome}</h2></div>"
    retorno << "<table id='tabela_porcentagem_presencas'><tr>"
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
    retorno << "<div id='graficos'>"
    retorno << "</div>"
    retorno <<
    "<script>
    Highcharts.visualize = function(table, options) {
     console.log(options);
      options.xAxis.categories = new Array();
      $('tbody th', table).each( function(i) {
        options.xAxis.categories.push(this.innerHTML);
      });
      console.log(table);
      console.log(options);
      options.series = [];
      $('tr', table).each( function(i) {
        var tr = this;
        $('th, td', tr).each( function(j) {
          if (j == 2) {
            if (i == 0) {
              options.series[j - 1] = {
                name: this.innerHTML,
                data: []
              };
            }
          } else {
            options.series[j - 1].data.push(parseFloat(this.innerHTML));
          }
        });
      });
      var chart = new Highcharts.Chart(options);
    }

    $(document).ready(function() {
      var table = document.getElementById('tabela_porcentagem_presencas'),
      options = {
        chart: {
          renderTo: 'graficos',
          defaultSeriesType: 'column'
        },
        title: {
          text: 'Estatisticas de Faltas por dia da semana'
        },
        xAxis: {

        },
        yAxis: {
          title: {
            text: 'Units'
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
    render :inline => retorno.html_safe, :layout => true
  end
end
