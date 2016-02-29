class AlterColumnConciliamentoDeId < ActiveRecord::Migration
  def up
    change_column :conciliamentos, :de_id, :integer, :null => true
  end

  def down
    change_column :conciliamentos, :de_id, :integer, :null => false
  end
end
