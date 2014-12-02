# -*- encoding : utf-8 -*-
class CreateRegistrosDePonto < ActiveRecord::Migration
  def change
    create_table :registros_de_ponto do |t|
      t.string :hora_de_chegada, :limit => 5
      t.string :hora_de_saida, :limit => 5
      t.date :data
      t.integer :pessoa_id

      t.timestamps
    end
  end
end
