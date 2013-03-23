class Aluno < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :telefones, :endereco

  has_many :telefones
  belongs_to :endereco
  has_one :matricula
  has_many :presencas

  def label
    nome
  end

  SEX = %w(M F)
end
