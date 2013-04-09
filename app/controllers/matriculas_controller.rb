#coding: utf-8
class MatriculasController < ApplicationController
  active_scaffold :matricula do |conf|
    conf.label = "Matrículas"
    conf.columns[:data_matricula].label = "Data de Matrícula"
    conf.columns[:data_inicio].label = "Data de Início"
    conf.columns[:data_fim].label = "Data de Fim"
    conf.columns[:numero_de_aulas_previstas].label = "Número de Aulas Previstas"
    conf.columns[:horario_de_aula].label = "Horário de Aula"
    conf.columns = [:aluno, :data_matricula, :data_inicio, :data_fim, :numero_de_aulas_previstas, :objetivo, :horario_de_aula]
    conf.columns[:horario_de_aula].show_blank_record = false
    conf.columns[:aluno].form_ui = :select
  end
end
