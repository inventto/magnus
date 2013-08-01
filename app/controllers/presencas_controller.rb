#coding: utf-8
class PresencasController < ApplicationController
  active_scaffold :presenca do |conf|
    #list.per_page = 64
    conf.label = "Presenças"
    conf.columns[:presenca].label = "Presença"
    conf.columns[:horario].label = "Horário"
    conf.columns[:realocacao].label = "Realocação de Horário"
#    conf.columns[:fora_de_horario].label = "Fora de Horário"
    conf.columns[:tem_direito_a_reposicao].label = "Tem Direito à Reposição?"
    conf.columns[:data_de_realocacao].label = "Realocado de"
    conf.columns = [:aluno, :data, :horario, :pontualidade, :presenca, :realocacao, :data_de_realocacao, :tem_direito_a_reposicao, :aula_extra, :justificativa_de_falta]
    conf.columns[:aluno].form_ui = :select
    conf.columns[:justificativa_de_falta].allow_add_existing = false
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:aluno, :data, :horario, :pontualidade, :presenca, :realocacao, :data_de_realocacao, :tem_direito_a_reposicao, :aula_extra, :justificativa_de_falta]
    list.sorting = [{:data => 'DESC'}, {:horario => 'DESC'}]
  end

  def self.condition_for_justificativa_de_falta_column(column, value, like_pattern)
    if value.include? "Não"
      "justificativas_de_falta.id is null"
    elsif value == "Possui"
      "justificativas_de_falta.id is not null"
    end
  end

  def update_respond_to_html
    redirect_to redirect_page_to_index
  end

  def redirect_page_to_index
    url = (is_last_page_agenda_do_dia?) ? agenda_do_dia_path : presencas_path
    url
  end

  def verifica_ultima_pagina_acessada
    session[:latest_pages_visited].delete_at(session[:latest_pages_visited].length - 1) if is_last_page_agenda_do_dia?
    render :nothing => true
  end

  def is_last_page_agenda_do_dia?
    length = session[:latest_pages_visited].length
    last_page_visited = session[:latest_pages_visited][length - 2]
    last_page_visited[:controller] == "agenda_do_dia"
  end
end
