class GeraConciliamentos < ActiveRecord::Migration
  def change
    Presenca.all.each do |presenca|
      presenca.send(:conciliamento_de_presencas)
    end
  end
end
