#coding: utf-8
module ApplicationHelper
  def status_presenca aluno_id, presenca_id
    presenca = Presenca.joins("LEFT JOIN justificativas_de_falta ON presencas.id=presenca_id")
    if presenca_id.blank?
      presenca = presenca.where(:aluno_id => aluno_id, :data => Time.now).where("reposicao is null or reposicao = false")
    else
      presenca = presenca.where(:id => presenca_id)
    end
    if not presenca.blank?
      presenca = presenca[0]
      if presenca.presenca
        retorno = ""
        retorno = "<img src='/assets/presenca.png' title='Presença Registrada' />"
        if presenca.reposicao
          retorno << "<img src='/assets/reposicao.png' title='Reposição' />"
        end
        if presenca.fora_de_horario
          retorno = "<img src='/assets/fora_de_horario.png' title='Fora de Horario' />"
        end
        return retorno.html_safe
      else
        if presenca.justificativa_de_falta.nil?
          retorno = "<img src='/assets/falta_sem_justif.png' title='Falta Sem Justificativa' />".html_safe
        else
          retorno = "<img src='/assets/falta_justif.png' title='Falta Justificada' />".html_safe
        end
        if presenca.reposicao
          retorno << "<img src='/assets/reposicao.png' title='Reposição' />".html_safe
        end
        return retorno
      end
    end
  end
end
