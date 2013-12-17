class Relatorio < ActiveRecord::Base
  attr_accessible :consulta, :nome, :titulos

  def label
    nome
  end
end
