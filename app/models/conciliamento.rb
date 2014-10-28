class Conciliamento < ActiveRecord::Base
  belongs_to :de, class_name: "Presenca"
  belongs_to :para, class_name: "Presenca"
  belongs_to :conciliamento_condition, polymorphic: true
  attr_accessible :tipo, :para_id, :de_id, :conciliamento_condition_id, :conciliamento_condition_type

  scope :em_aberto, -> { where(para_id: nil) }

  def expirar!
   expirada = Expirada.new 
   expirada.conciliamento = self
   expirada.save
   conciliamento_condition.destroy 
  end

end
