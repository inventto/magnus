class Concilio < ActiveRecord::Base
  belongs_to :de, class_name: "Presenca"
  belongs_to :para, class_name: "Presenca"
  attr_accessible :tipo

  scope :reposicao, -> { where(tipo: 'reposicao') }
  scope :em_aberto, -> { where(para_id: nil) }
end
