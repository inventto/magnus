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
    retorno << "<div class='active-scaffold-header'><h2>#{relatorio.nome}</h2></div>"
    if relatorio.id == 2
    retorno << "<table id='tabela_porcentagem_presencas'><tr>"
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
    end
    retorno <<
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
    render :inline => retorno.html_safe, :layout => true
  end
end
