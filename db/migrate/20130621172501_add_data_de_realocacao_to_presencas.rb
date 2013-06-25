class AddDataDeRealocacaoToPresencas < ActiveRecord::Migration
  def self.up
    add_column :presencas, :data_de_realocacao, :date
  end

  def self.down
    remove_column :presencas, :data_de_realocacao
  end
end
