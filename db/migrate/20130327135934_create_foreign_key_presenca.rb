require "migration_helpers"
include MigrationHelpers

class CreateForeignKeyPresenca < ActiveRecord::Migration

  def up
    foreign_key(:justificativas_de_falta, :presenca_id, :presencas)
  end

  def down
    drop_foreign_key(:justificativas_de_falta, :presenca_id)
  end
end
