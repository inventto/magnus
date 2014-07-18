class AddExpiradaToPresenca < ActiveRecord::Migration
  def self.up
    add_column :presencas, :expirada, :boolean, default: false
    Pessoa.all.each {|p| Presenca.set_faltas_expiradas(p.id)}
  end

  def self.down
    remove_column :presencas, :expirada
  end
end
