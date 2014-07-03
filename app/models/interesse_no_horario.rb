#encoding: utf-8
class InteresseNoHorario < ActiveRecord::Base
  belongs_to :matricula
  attr_accessible :ativo, :descricao, :dia_da_semana, :horario, :matricula_id

  scope :por_horario, ->(horario, dia_da_semana) { where(:horario => horario, :dia_da_semana => dia_da_semana) }

  DIAS = {:"Domingo" => "0", :"Segunda" => "1", :"Terça" => "2", :"Quarta" => "3", :"Quinta" => "4", :"Sexta" => "5", :"Sábado" => "6"}
  #HORARIOS ={:"05:30" => "0", :"06:00" => "1", :"07:00" => "2", :"08:00" => "3", :"09:00" => "09:00", :"10:00" => "10:00", :"11:00" => "11:00", :"12:00" => "12:00", :"13:00" => "13:00", :"14:00" => "14:00", :"15:00" => "15:00", :"16:00" => "16:00", :"17:00" => "17:00", :"18:00" => "18:00", :"19:00" => "19:00", :"20:00" => "20:00", :"21:00" => "21:00", :"22:00" => "22:00", :"23:00" => "23:00"}
end
