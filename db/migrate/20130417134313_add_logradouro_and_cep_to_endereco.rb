class AddLogradouroAndCepToEndereco < ActiveRecord::Migration
  def self.up
    add_column :enderecos, :logradouro, :string
    add_column :enderecos, :cep, :string
  end

  def self.down
    remove_column :enderecos, :logradouro
    remove_column :enderecos, :cep
  end
end
