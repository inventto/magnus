# -*- encoding : utf-8 -*-
class CreateConciliamentos < ActiveRecord::Migration
  def change
    create_table :conciliamentos do |t|
      t.string :tipo
      t.references :de, null: false
      t.references :para

      t.timestamps
    end
    add_index :conciliamentos, :de_id
    add_index :conciliamentos, :para_id
  end
end
