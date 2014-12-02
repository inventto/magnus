# -*- encoding : utf-8 -*-
class CreateFeriados < ActiveRecord::Migration
  def change
    create_table :feriados do |t|
      t.string :descricao
      t.boolean :feriado_fixo
      t.boolean :repeticao_anual
      t.integer :dia
      t.integer :mes
      t.integer :ano

      t.timestamps
    end
  end
end
