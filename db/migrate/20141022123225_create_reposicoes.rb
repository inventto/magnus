class CreateReposicoes < ActiveRecord::Migration
  def change
    create_table :reposicoes do |t|
      t.references :conciliamento

      t.timestamps
    end
    add_index :reposicoes, :conciliamento_id
  end
end
