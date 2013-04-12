module ApplicationHelper
  def presenca aluno_id
    presenca = Presenca.where(:aluno_id => aluno_id, :data => Time.now)
    if not presenca.blank?
      if presenca[0][:presenca]
        return "P"
      end
    end
  end
end
