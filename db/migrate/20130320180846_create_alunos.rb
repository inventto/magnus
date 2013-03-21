class CreateAlunos < ActiveRecord::Migration
  def change
    create_table :alunos do |t|
      t.string :nome
      t.string :foto
      t.date :data_nascimento
      t.string :sexo
      t.string :email
      t.integer :endereco_id

      t.timestamps
    end
  end
end
