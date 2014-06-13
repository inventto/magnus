#coding: utf-8
class MatriculasController < ApplicationController
  active_scaffold :matricula do |conf|
    conf.label = "Matrículas"
    conf.columns[:data_matricula].label = "Data de Matrícula"
    conf.columns[:data_inicio].label = "Data de Início"
    conf.columns[:data_fim].label = "Data de Interrupção"
    conf.columns[:inativo_desde].label = "Inativo Desde"
    conf.columns[:inativo_ate].label = "Inativo até"
    conf.columns[:numero_de_aulas_previstas].label = "Número de Aulas Previstas"
    conf.columns[:horario_de_aula].label = "Horário de Aula"
    conf.columns[:interesse]
    conf.columns[:motivo_da_interrupcao].label = "Motivo da Interrupção"
    conf.columns[:pessoa].label = "Aluno"
    conf.list.columns = [:pessoa, :vip, :data_matricula, :data_inicio, :data_fim, :motivo_da_interrupcao, :numero_de_aulas_previstas, :objetivo, :horario_de_aula, :interesse]
    conf.columns = [:pessoa, :vip, :data_matricula, :data_inicio, :inativo_desde, :inativo_ate, :data_fim, :motivo_da_interrupcao, :numero_de_aulas_previstas, :objetivo, :horario_de_aula, :interesse]
    conf.columns[:horario_de_aula].show_blank_record = false
    conf.columns[:pessoa].form_ui = :select
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    #conf.field_search.default_params = {:data_fim => {"from" => Time.now.strftime("%Y-%m-%d"), "to" => "", "opt" => ">="}}
  end

  protected
    def custom_finder_options
      {:reorder => "pessoas.nome ASC"}
    end
end
