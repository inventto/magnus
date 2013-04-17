class Telefone < ActiveRecord::Base
  attr_accessible :aluno_id, :ddd, :descricao, :numero, :ramal, :tipo_telefone_id, :tipo_telefone

  belongs_to :tipo_telefone
  belongs_to :aluno

  def label
    desc = ""
    desc = "(" << ddd << ") "
    numero = self.numero.gsub(/\D/,"")
    desc << numero[0..3] << " -  " << numero[4..8]
    desc
  end
end
