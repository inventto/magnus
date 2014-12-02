# -*- encoding : utf-8 -*-
class LoadTiposDeTelefone < ActiveRecord::Migration
  def up
    TipoTelefone.create(:descricao => "Residencial")
    TipoTelefone.create(:descricao => "Comercial")
    TipoTelefone.create(:descricao => "Celular")
  end

  def down
    TipoTelefone.detroy_all
  end
end
