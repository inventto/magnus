# -*- encoding : utf-8 -*-
class CreateConciliamentoConditions < ActiveRecord::Migration
  def change
    add_column :conciliamentos, :conciliamento_condition_id, :integer
    add_column :conciliamentos, :conciliamento_condition_type, :string
  end
end
