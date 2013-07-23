class AddAulaExtraToPresencas < ActiveRecord::Migration
  def self.up
    add_column :presencas, :aula_extra, :boolean, :default => false
  end

  def self.down
    remove_column :presencas, :aula_extra
  end
end
