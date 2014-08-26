module RelatoriosHelper
  def script_graficos
   script = " <script>
    $(function () {
        $('#graficos').highcharts({
          data: {
            table: document.getElementById('tabela_porcentagem_presencas')
          },
          chart: {
            type: 'column'
          },
          title:
            text: 'Estatísticas de Faltas por dia da semana'
          },
          yAxis: {
            allowDecimals: false,
            title: {
              text: 'Units'
            }
          },
          tooltip: {
            formatter: function () {
               return '<b>' + this.series.name + '</b><br/>' +
                 this.point.y + ' ' + this.point.name.toLowerCase();
            }
          }
      });
    });
    </script>
    ".html_safe
  end
end
