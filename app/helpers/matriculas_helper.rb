# -*- encoding : utf-8 -*-
module MatriculasHelper

   def horario_de_aula_column(record, column)
    raw(record.horario_de_aula.collect do |horario|
      horario.label
    end.join "<br/>")
  end
end
