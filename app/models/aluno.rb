#coding: utf-8
class Aluno < ActiveRecord::Base
  attr_accessible :data_nascimento, :email, :endereco_id, :foto, :nome, :sexo, :cpf, :telefones, :endereco

  has_many :telefones, :dependent => :destroy
  belongs_to :endereco
  has_one :matricula, :dependent => :destroy
  has_many :presencas, :dependent => :destroy

  validates_format_of :email, :with => /^([[^õüãáéíóúç]^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Inválido!'
  validates :cpf, :presence => true, :numericality => true, :length => { :is => 11 }

  SEX = %w(M F)

  def label
    desc = ""
    desc = nome << " -  "
    desc << cpf[0..2] << "." << cpf[3..5] << "." << cpf[6..8] << "-" << cpf[9..11]
  end
end
