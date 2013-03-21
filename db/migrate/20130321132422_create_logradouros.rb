class CreateLogradouros < ActiveRecord::Migration
  def change
    create_table :logradouros do |t|
      t.string :nome
      t.string :cep
      t.integer :bairro_id

      t.timestamps
    end
  end
end
