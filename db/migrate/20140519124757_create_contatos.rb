# -*- encoding : utf-8 -*-
class CreateContatos < ActiveRecord::Migration
  def change
    create_table :contatos do |t|
      t.text :descricao
      t.date :data_contato
      t.references :pessoa

      t.timestamps
    end
    add_index :contatos, :pessoa_id
  end
end
