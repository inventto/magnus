class FeriadosController < ApplicationController
  active_scaffold :feriado do |conf|
    conf.columns = [:descricao, :feriado_fixo, :repeticao_anual, :dia, :mes, :ano]
  end
end
