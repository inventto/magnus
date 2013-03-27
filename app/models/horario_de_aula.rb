#coding: utf-8
class HorarioDeAula < ActiveRecord::Base
  attr_accessible :dia_da_semana, :horario, :matricula_id

  belongs_to :matricula

  DIAS = {:"Domingo"=> "0", :"Segunda" => "1", :"Terça" => "2", :"Quarta" => "3", :"Quinta" => "4", :"Sexta" => "5", :"Sábado" => "6"}

  def label
    desc = ""
    desc = choice_day_of_week(dia_da_semana)
    desc << " - " << horario << " h"
    desc
  end

  def choice_day_of_week day
    if day == 0
      return "Domingo"
    elsif day == 1
      return "Segunda"
    elsif day == 2
      return "Terça"
    elsif day == 3
      return "Quarta"
    elsif day == 4
      return "Quinta"
    elsif day == 5
      return "Sexta"
    else
      return "Sábado"
    end
  end
end
