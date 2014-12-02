# -*- encoding : utf-8 -*-
class AddEFuncionarioToPessoas < ActiveRecord::Migration
  def up
    add_column :pessoas, :e_funcionario, :boolean, :default => false
  end

  def down
    remove_column :pessoas, :e_funcionario
  end
end
