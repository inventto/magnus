#coding: UTF-8
class LoadEstados < ActiveRecord::Migration
  def self.up
    estados = File.open("estados.txt")
    estados.lines.each do |line|
      estado = line.match(/(.+\w+[áéíóúãô]?) - (\w+)/)
      Estado.create(:nome => estado[1], :sigla => estado[2])
    end
  end

  def self.down
    Estado.destroy_all
  end
end
