require "migration_helpers"
include MigrationHelpers

class CreateForeignKeyAluno < ActiveRecord::Migration
  def up
    foreign_key(:matriculas, :aluno_id, :alunos)
    foreign_key(:telefones, :aluno_id, :alunos)
    foreign_key(:presencas, :aluno_id, :alunos)
  end

  def down
    drop_foreign_key(:matriculas, :aluno_id)
    drop_foreign_key(:telefones, :aluno_id)
    drop_foreign_key(:presencas, :aluno_id)
  end
end
