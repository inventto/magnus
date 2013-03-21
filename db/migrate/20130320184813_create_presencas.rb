class CreatePresencas < ActiveRecord::Migration
  def change
    create_table :presencas do |t|
      t.integer :aluno_id
      t.date :data
      t.string :horario
      t.boolean :presenca

      t.timestamps
    end
  end
end
