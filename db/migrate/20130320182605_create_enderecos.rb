# -*- encoding : utf-8 -*-
class CreateEnderecos < ActiveRecord::Migration
  def change
    create_table :enderecos do |t|
      t.integer :cidade_id
      t.integer :bairro_id
      t.integer :logradouro_id
      t.string :numero
      t.string :complemento
      t.string :cep

      t.timestamps
    end
  end
end
