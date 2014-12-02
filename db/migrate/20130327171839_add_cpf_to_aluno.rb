# -*- encoding : utf-8 -*-
class AddCpfToAluno < ActiveRecord::Migration
  def self.up
    add_column :alunos, :cpf, :string
  end
  def self.down
    remove_column :alunos, :cpf
  end
end
