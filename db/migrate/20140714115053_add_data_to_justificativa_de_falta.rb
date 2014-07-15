class AddDataToJustificativaDeFalta < ActiveRecord::Migration
  def self.up
    add_column :justificativas_de_falta, :data, :date
  end

  def self.down
    remove_column :justificativas_de_falta, :data
  end
end
