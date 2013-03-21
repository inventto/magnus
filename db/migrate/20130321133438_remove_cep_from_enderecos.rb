class RemoveCepFromEnderecos < ActiveRecord::Migration
  def up
    remove_column :enderecos, :cep
  end

  def down
    add_column :enderecos, :cep, :string
  end
end
