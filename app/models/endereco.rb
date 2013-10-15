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

  def completo
    address = ""
    if not self.blank?
      endereco = self
      if endereco.logradouro
        address << endereco.logradouro
      end
      if endereco.numero
        address << ", " << endereco.numero
      end
      if endereco.complemento
        address << " - " << endereco.complemento
      end
      if endereco.bairro
        address << " - " << endereco.bairro.nome
      end
      if endereco.cidade
        address << " - " << endereco.cidade.nome.chomp << "/" << endereco.cidade.estado.sigla
      end
      if endereco.cep
        address << " - " << endereco.cep
      end
    end
    address
  end
end
