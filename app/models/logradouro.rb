class Logradouro < ActiveRecord::Base
  attr_accessible :bairro_id, :cep, :nome

  belongs_to :bairro

  def label
    nome
  end
end
