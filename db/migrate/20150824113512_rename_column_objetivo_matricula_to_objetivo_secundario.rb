class RenameColumnObjetivoMatriculaToObjetivoSecundario < ActiveRecord::Migration
  def up
    rename_column :matriculas, :objetivo, :objetivo_secundario
  end

  def down
    rename_column :matriculas, :objetivo_secundario, :objetivo
  end
end
