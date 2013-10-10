class Endereco < ActiveRecord::Base
   attr_accessible :cep, :logradouro, :numero, :complemento, :bairro_id, :cidade_id
  has_one :pessoa
  belongs_to :bairro
  belongs_to :cidade

  def label
    descricao = ""
    if logradouro
      descricao << logradouro
    end
    if numero
      descricao << "-" << numero
    end
    descricao
  end
end
