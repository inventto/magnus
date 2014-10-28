class Expirada < ActiveRecord::Base
  has_one :conciliamento, as: :conciliamento_condition

  delegate :de_id, :de_id=, :para_id, :para_id=, to: :conciliamento
end
