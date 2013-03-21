class CreateTelefones < ActiveRecord::Migration
  def change
    create_table :telefones do |t|
      t.string :ddd
      t.string :numero
      t.integer :tipo_telefone_id
      t.string :descricao
      t.string :ramal
      t.integer :aluno_id

      t.timestamps
    end
  end
end
