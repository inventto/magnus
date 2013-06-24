class AddMotivoDaInterrupcaoToMatriculas < ActiveRecord::Migration
  def self.up
    add_column :matriculas, :motivo_da_interrupcao, :string
  end

  def self.down
    remove_column :matriculas, :motivo_da_interrupcao
  end
end
