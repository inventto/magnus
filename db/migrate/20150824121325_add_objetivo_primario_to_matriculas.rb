class AddObjetivoPrimarioToMatriculas < ActiveRecord::Migration
  def self.up 
    add_column :matriculas, :objetivo_primario, :string
  end

  def self.down
    add_column :matriculas, :objetivo_primario
  end
end
