#coding: utf-8
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

  validates_format_of :email, :with => /^([[^õüãáéíóúç]^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Inválido!'

end
