class AddIndexToPessoas < ActiveRecord::Migration
  def change
    add_index :pessoas, :id, :unique => true
  end
end
