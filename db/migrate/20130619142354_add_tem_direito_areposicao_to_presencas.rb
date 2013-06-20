class AddTemDireitoAreposicaoToPresencas < ActiveRecord::Migration
  def self.up
    add_column :presencas, :tem_direito_a_reposicao, :boolean
  end

  def self.down
    remove_column :presencas, :tem_direito_a_reposicao
  end
end
