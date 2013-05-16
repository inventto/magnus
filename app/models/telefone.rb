class Telefone < ActiveRecord::Base
  attr_accessible :aluno_id, :ddd, :descricao, :numero, :ramal, :tipo_telefone_id, :tipo_telefone

  belongs_to :tipo_telefone
  belongs_to :aluno

  def label
    desc = ""
    desc = "(" << self.ddd.gsub(/\D/,"") << ") "
    numero = self.numero.gsub(/\D/,"")
    if numero.length == 8
      desc << numero[0..3] << " -  " << numero[4..8]
    elsif numero.length == 9
      desc << numero[0..4] << " -  " << numero[5..9]
    else
      desc << numero
    end
    desc
  end
end
