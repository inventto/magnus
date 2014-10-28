class CreateExpiradas < ActiveRecord::Migration
  def change
    create_table :expiradas do |t|
      t.references :conciliamento

      t.timestamps
    end
    add_index :expiradas, :conciliamento_id
  end
end
