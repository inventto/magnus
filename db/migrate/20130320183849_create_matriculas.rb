class CreateMatriculas < ActiveRecord::Migration
  def change
    create_table :matriculas do |t|
      t.integer :aluno_id
      t.string :objetivo
      t.date :data_matricula
      t.date :data_inicio
      t.date :data_fim
      t.integer :numero_de_aulas_previstas

      t.timestamps
    end
  end
end
