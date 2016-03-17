class AlterColumnTemDireitoAReposicaoToPresenca < ActiveRecord::Migration
  def up
    change_column :presencas, :tem_direito_a_reposicao, :boolean, :default => false, :null => false
  end

  def down
    change_column :presencas, :tem_direito_a_reposicao, :boolean, :default => nil, :null => true
  end
end
