# -*- encoding : utf-8 -*-
class CreateTiposTelefone < ActiveRecord::Migration
  def change
    create_table :tipos_telefone do |t|
      t.string :descricao

      t.timestamps
    end
  end
end
