class Feriado < ActiveRecord::Base
  attr_accessible :ano, :descricao, :dia, :feriado_fixo, :mes, :repeticao_anual
end
