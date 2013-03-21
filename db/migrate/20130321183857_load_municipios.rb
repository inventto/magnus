class LoadMunicipios < ActiveRecord::Migration
  def self.up
    municipios = File.open("/home/lucas/inventto/magnus/controle_de_presenca_magnus/municipios_parana.txt")
    municipios.lines.each do |municipio|
      Cidade.create(:nome => municipio, :estado_id => 20)# Todas as cidades são do Paraná
    end
  end

  def self.down
    Cidade.detroy_all
  end
end
