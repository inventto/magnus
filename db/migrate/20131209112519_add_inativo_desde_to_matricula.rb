# -*- encoding : utf-8 -*-
class AddInativoDesdeToMatricula < ActiveRecord::Migration
  def self.up
    add_column :matriculas, :inativo_desde, :Date
     Matricula.all.each do |m|
      if m.inativo_ate and m.inativo_ate.to_time > Time.now
        m.inativo_desde = Time.now
        m.save
      end
    end
  end

  def self.down
      remove_column :matriculas, :inativo_desde
  end
end
