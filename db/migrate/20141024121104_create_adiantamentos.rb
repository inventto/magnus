class CreateAdiantamentos < ActiveRecord::Migration
  def change
    create_table :adiantamentos do |t|
      t.timestamps
    end
  end
end
