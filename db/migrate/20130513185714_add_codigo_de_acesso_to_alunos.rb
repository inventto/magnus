class AddCodigoDeAcessoToAlunos < ActiveRecord::Migration
  def self.up
    add_column :alunos, :codigo_de_acesso, :string
  end

  def self.down
    remove_column :alunos, :codigo_de_acesso
  end
end
