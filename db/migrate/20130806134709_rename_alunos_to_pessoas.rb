class RenameAlunosToPessoas < ActiveRecord::Migration
  def up
    rename_table :alunos, :pessoas
  end

  def down
    rename_table :pessoas, :alunos
  end
end
