class CreateReposicoes < ActiveRecord::Migration
  def change
    create_table :reposicoes do |t|
      t.timestamps
    end
  end
end
