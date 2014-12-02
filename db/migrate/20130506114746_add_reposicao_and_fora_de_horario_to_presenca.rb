# -*- encoding : utf-8 -*-
class AddReposicaoAndForaDeHorarioToPresenca < ActiveRecord::Migration
  def self.up
    add_column :presencas, :reposicao, :boolean
    add_column :presencas, :fora_de_horario, :boolean
  end

  def self.down
    remove_column :presencas, :reposicao
    remove_column :presencas, :fora_de_horario
  end
end
