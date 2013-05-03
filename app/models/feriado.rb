class Feriado < ActiveRecord::Base
  attr_accessible :ano, :descricao, :dia, :feriado_fixo, :mes, :repeticao_anual

  validates :ano, :numericality => true, :length => {:is => 4}, :if => "not ano.blank? or not repeticao_anual"
  validates :mes, :numericality => true, :length => {:maximum => 2}
  validates :dia, :numericality => true, :length => {:maximum => 2}

  def label
    descricao
  end
end
