#coding: utf-8
module PresencasHelper
  def pessoa_column(record, column)
    nome = record.pessoa.nome << "<br/>"
    fones = []
    if not record.pessoa.telefones.nil?
      record.pessoa.telefones.each do |telefone|
        fones << telefone.label
      end
    end
    fones = "<div class='fones'>" << fones.join("<br/>") << "</div>"
    raw(nome + fones)
  end

  def justificativa_de_falta_search_column(record, html_options)
    selected = html_options.delete :value

    select_options = ["Não Possui", "Possui"]

    options = { :selected => selected,
                :include_blank => as_(:_select_)}
    select(:record, :justificativa_de_falta, select_options, options, html_options)
  end
end
