class Reposicao < ActiveRecord::Base
  belongs_to :conciliamento
   
  delegate :para_id, :de_id, to: :conciliamento

  after_initialize :initialize_attributes

  def initialize_attributes
    self.conciliamento ||= Conciliamento.new
  end

end
