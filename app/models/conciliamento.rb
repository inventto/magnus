class Conciliamento < ActiveRecord::Base
  has_one :de, class_name: "Presenca"
  has_one :para, class_name: "Presenca"
  attr_accessible :tipo, :para_id

  scope :reposicao, -> { where(tipo: 'reposicao') }
  scope :em_aberto, -> { where(para_id: nil) }

end
