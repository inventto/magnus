class Conciliamento < ActiveRecord::Base
  has_one :de, class_name: "Presenca"
  has_one :para, class_name: "Presenca"
  belongs_to :conciliamento_condition, polymorphic: true
  attr_accessible :tipo, :para_id, :de_id, :conciliamento_condition_id, :conciliamento_condition_type

  scope :em_aberto, -> { where(para_id: nil) }

end
