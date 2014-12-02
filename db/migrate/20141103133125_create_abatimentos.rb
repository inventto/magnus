# -*- encoding : utf-8 -*-
class CreateAbatimentos < ActiveRecord::Migration
  def change
    create_table :abatimentos do |t|

      t.timestamps
    end
  end
end
