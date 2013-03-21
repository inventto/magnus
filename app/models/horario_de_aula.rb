class HorarioDeAula < ActiveRecord::Base
  attr_accessible :dia_da_semana, :horario, :matricula_id
  belongs_to :matricula
end
