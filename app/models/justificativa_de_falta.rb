#encoding: utf-8
class JustificativaDeFalta < ActiveRecord::Base
  attr_accessible :descricao, :data, :hora

  validates_presence_of :descricao
  regex_hora =/(^\d{2})+([:])(\d{2}$)/
  validates_format_of :hora, with: regex_hora, :message => 'inválida!'

  belongs_to :presenca

  def label
    descricao
  end

end
