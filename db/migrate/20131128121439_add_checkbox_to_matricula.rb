# -*- encoding : utf-8 -*-
class AddCheckboxToMatricula < ActiveRecord::Migration
  def self.up
    add_column :matriculas, :standby, :boolean, :default => false
  end

  def self.down
    remove_column :matriculas, :standby
  end
end
