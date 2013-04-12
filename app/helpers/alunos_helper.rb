module AlunosHelper
  #  def aluno_sexo_form_column(record, options)
  #    check_box :record, :is_admin, options, "Masculino", "Feminino"
  #  end
  def foto_column(model, column)
    "<img src='#{model.foto}' height='48'>".html_safe
  end

  def id_form_column(record, column)
    "<span class='id'>#{record.id}</span>"
  end
end
