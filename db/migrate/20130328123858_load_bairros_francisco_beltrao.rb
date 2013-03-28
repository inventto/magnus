class LoadBairrosFranciscoBeltrao < ActiveRecord::Migration
  def self.up
    bairros = File.open("db/migrate/bairros_francisco_beltrao.txt")
    bairros.lines.each do |bairro|
      Bairro.create(:nome => bairro, :cidade_id => Cidade.where("nome ilike 'francisco b%'")[0][:id])
    end
  end

  def self.down
    Bairro.destroy_all
  end
end
