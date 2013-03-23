class Telefone < ActiveRecord::Base
  attr_accessible :aluno_id, :ddd, :descricao, :numero, :ramal, :tipo_telefone_id, :tipo_telefone

  belongs_to :tipo_telefone
  belongs_to :aluno

  def label
    numero
  end
end
