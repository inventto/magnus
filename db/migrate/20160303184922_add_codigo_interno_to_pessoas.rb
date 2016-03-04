class AddCodigoInternoToPessoas < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :codigo_interno, :integer
  end

  def self.down
    add_column :pessoas, :codigo_interno
  end
end
