class AddTipoDePessoaToPessoa < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :tipo_de_pessoa, :integer, :default => 0
    Pessoa.reset_column_information
    Pessoa.all.each do |pessoa|

      pessoa.tipo_de_pessoa =
        if pessoa.e_funcionario?
          1
        else
          0
        end
      pessoa.save
    end
    remove_column :pessoas, :e_funcionario
  end

  def self.down
    add_column :pessoas, :e_funcionario, :boolean, :default => false
    Pessoa.reset_column_information
    Pessoa.all.each do |pessoa|
      pessoa.eh_funcionario = pessoa.tipo_de_pessoa > 0
      pessoa.save
    end
    remove_column :pessoas, :tipo_de_pessoa
  end
end
