#encoding: utf-8
module InteresseNoHorarioHelper
  def interesse_list_table dia, periodo
    puts "Entro"
    if @interessados_nos_horarios[dia]
      @interessados_nos_horarios[dia].each do |horario_da_aula, registros|
        content_tag(:td) do
          if horario_da_aula[0..1].to_i == periodo
            get_nomes_nos(registros)
          end
        end
      end
    end
  end

  def get_nomes_nos horarios
    horarios[1,2,3,4].collect do |registro|
    puts "Entro 2"
      ultimo_nome = []
      ultimo_nome = registro.matricula.pessoa.segundo_nome.split(" ")
      ultimo_nome = ultimo_nome[ultimo_nome.length - 1][0]
      content_tag(:ol) do
        content_tag(:li,  registro.matricula.pessoa.primeiro_nome )
      end
    end
  end
end
