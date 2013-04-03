#coding: utf-8
class LoadMunicipios < ActiveRecord::Migration
  def self.up
    municipios = File.open("db/migrate/municipios_parana.txt")
    municipios.lines.each do |municipio|
      Cidade.create(:nome => municipio, :estado_id => Estado.where("nome ilike 'Paraná'")[0][:id])# Todas as cidades são do Paraná
    end
  end

  def self.down
    Cidade.detroy_all
  end
end
