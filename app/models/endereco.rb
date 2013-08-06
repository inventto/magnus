class Endereco < ActiveRecord::Base
   attr_accessible :bairro_id, :cidade_id, :complemento, :logradouro, :numero, :cep
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
