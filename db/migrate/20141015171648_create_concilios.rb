class CreateConcilios < ActiveRecord::Migration
  def change
    create_table :concilios do |t|
      t.string :tipo
      t.references :de, null: false
      t.references :para

      t.timestamps
    end
    add_index :concilios, :de_id
    add_index :concilios, :para_id
  end
end
