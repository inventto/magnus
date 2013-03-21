class CreateHorariosDeAula < ActiveRecord::Migration
  def change
    create_table :horarios_de_aula do |t|
      t.integer :matricula_id
      t.string :horario
      t.integer :dia_da_semana

      t.timestamps
    end
  end
end
