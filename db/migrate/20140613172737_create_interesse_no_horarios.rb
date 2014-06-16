class CreateInteresseNoHorarios < ActiveRecord::Migration
  def change
    create_table :interesse_no_horarios do |t|
      t.boolean :ativo
      t.string :descricao
      t.string :horario
      t.integer :dia_da_semana
      t.references :matricula

      t.timestamps
    end
    add_index :interesse_no_horarios, :matricula_id
  end
end
