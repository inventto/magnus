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
    retorno << "<table><tr>"
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
    render :inline => retorno.html_safe, :layout => true
  end
end
