class AddExpiradaToPresenca < ActiveRecord::Migration
  def self.up
    add_column :presencas, :expirada, :boolean, default: false
    Pessoa.all.each do |p|
      p.set_faltas_expiradas(p.id)
      p.save!
    end
  end

  def self.down
    remove_column :presencas, :expirada
  end
end
