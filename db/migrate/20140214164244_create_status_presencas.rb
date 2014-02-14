class CreateStatusPresencas < ActiveRecord::Migration
  def up
    create_table :status_presencas do |t|
      t.string :descricao
      t.string :icone
      t.boolean :presenca, default: false
      t.boolean :direito_reposicao, default: false
      t.boolean :realocacao, default: false
      t.boolean :aula_extra, default: false
      t.boolean :justificavel, default: false
      t.timestamps
    
    end
  end
  def down
    drop_table :status_presencas
  end
end
