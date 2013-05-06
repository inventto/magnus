#coding: utf-8
module ApplicationHelper
  def presenca aluno_id
    presenca = Presenca.where(:aluno_id => aluno_id, :data => Time.now)
    if not presenca.blank?
      if presenca[0][:presenca]
        return "<img src='/assets/presenca.png' style='height: 30px;' title='Presença Registrada' />".html_safe
      else
        return ""
      end
    end
  end
end
