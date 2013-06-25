class FixReposicaoName < ActiveRecord::Migration
  def up
    rename_column :presencas, :reposicao, :realocacao
  end

  def down
    rename_column :presencas, :realocacao, :reposicao
  end
end
