class AddCorToPessoa < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :cor, :string
  end

  def self.down
    remove_column :pessoas, :cor
  end
end
