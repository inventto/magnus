class CreateRelatorios < ActiveRecord::Migration
  def change
    create_table :relatorios do |t|
      t.string :titulos
      t.string :nome
      t.string :consulta

      t.timestamps
    end
  end
end
