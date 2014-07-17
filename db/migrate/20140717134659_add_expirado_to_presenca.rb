class AddExpiradoToPresenca < ActiveRecord::Migration
  def self.up
    add_column :presencas, :expirada, :boolean
  end

  def self.down
    remove_column :presencas, :expirada
  end
end
