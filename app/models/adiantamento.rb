# -*- encoding : utf-8 -*-
class Adiantamento < ActiveRecord::Base
  after_initialize :initialize_attributes

  has_one :conciliamento, as: :conciliamento_condition

  delegate :de_id, :de_id=, :para_id, :para_id=, to: :conciliamento

  def initialize_attributes
    self.conciliamento ||= Conciliamento.new
  end
end
