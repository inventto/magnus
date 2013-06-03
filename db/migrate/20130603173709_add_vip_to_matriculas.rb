class AddVipToMatriculas < ActiveRecord::Migration
  def self.up
    add_column :matriculas, :vip, :boolean
  end

  def self.down
   remove_column :matriculas, :vip
  end
end
