class CreateJustificativasDeFalta < ActiveRecord::Migration
  def change
    create_table :justificativas_de_falta do |t|
      t.string :descricao
      t.integer :presenca_id

      t.timestamps
    end
  end
end
