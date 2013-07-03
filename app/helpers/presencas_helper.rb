#coding: utf-8
module PresencasHelper
  def justificativa_de_falta_search_column(record, html_options)
    selected = html_options.delete :value

    select_options = ["Não Possui", "Possui"]

    options = { :selected => selected,
                :include_blank => as_(:_select_)}
    select(:record, :justificativa_de_falta, select_options, options, html_options)
  end
end
