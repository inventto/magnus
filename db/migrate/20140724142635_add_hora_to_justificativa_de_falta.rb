# -*- encoding : utf-8 -*-
class AddHoraToJustificativaDeFalta < ActiveRecord::Migration
  def self.up
    add_column :justificativas_de_falta, :hora, :string
  end

  def self.down
    remove_column :justicativas_de_falta, :hora
  end
end
