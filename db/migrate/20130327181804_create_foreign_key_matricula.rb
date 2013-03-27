require "migration_helpers"
include MigrationHelpers

class CreateForeignKeyMatricula < ActiveRecord::Migration
  def up
    foreign_key(:horarios_de_aula, :matricula_id, :matriculas)
  end

  def down
    drop_foreign_key(:horarios_de_aula, :matricula_id)
  end
end
