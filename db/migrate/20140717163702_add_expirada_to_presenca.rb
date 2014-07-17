class AddExpiradaToPresenca < ActiveRecord::Migration
  def self.up
    add_column :presencas, :expirada, :boolean, default: false
  end

  def self.down
    remove_column :presencas, :expirada
  end
end
