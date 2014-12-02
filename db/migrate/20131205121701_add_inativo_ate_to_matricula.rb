# -*- encoding : utf-8 -*-
class AddInativoAteToMatricula < ActiveRecord::Migration
  def self.up
    add_column :matriculas, :inativo_ate, :date
    Matricula.all.each do |m|
      if m.standby
        m.inativo_ate = Time.mktime(2014,02,01)
        m.save
      end
    end
    remove_column :matriculas, :standby
  end

  def self.down
    add_column :matriculas, :standby, :boolean
     Matricula.all.each do |m|
      if m.inativo_ate and m.inativo_ate.to_time > Time.now
        m.standby = true
        m.save
      end
    end
    remove_column :matriculas, :inativo_ate
  end
end
