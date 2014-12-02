# -*- encoding : utf-8 -*-
class RenameAlunoIdToPessoaId < ActiveRecord::Migration
  def up
    rename_column :matriculas, :aluno_id, :pessoa_id
    rename_column :presencas,  :aluno_id, :pessoa_id
    rename_column :telefones,  :aluno_id, :pessoa_id
  end

  def down
    rename_column :matriculas, :pessoa_id, :aluno_id
    rename_column :presencas,  :pessoa_id, :aluno_id
    rename_column :telefones,  :pessoa_id, :aluno_id
  end
end
