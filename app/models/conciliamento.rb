class Conciliamento < ActiveRecord::Base
  has_one :de, class_name: "Presenca"
  has_one :para, class_name: "Presenca"
  has_many :reposicoes
  attr_accessible :tipo, :para_id, :de_id

  scope :em_aberto, -> { where(para_id: nil) }

end
