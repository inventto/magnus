# -*- encoding : utf-8 -*-
class AddPontualidadeToPresencas < ActiveRecord::Migration
  def self.up
    add_column :presencas, :pontualidade, :integer
  end

  def self.down
    remove_column :presencas, :pontualidade
  end
end
