#encoding: utf-8
module InteresseNoHorarioHelper
  def get_nomes_nos horarios
    horarios[0,4].collect do |registro|
      ultimo_nome = []
      ultimo_nome = registro.matricula.pessoa.segundo_nome.split(" ")
      ultimo_nome = ultimo_nome[ultimo_nome.length - 1][0]
      content_tag(:ol){
        content_tag(:li,  "#{registro.matricula.pessoa.primeiro_nome} #{ultimo_nome}.")
      }
    end
  end
end
