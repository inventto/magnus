#coding: utf-8
alunos = Pessoa.order(:id).all
alunos.each do |aluno|
  param_nome_municipio = {}
  if not aluno.endereco.nil? and not aluno.endereco.cidade.nil?
    if (nome = aluno.endereco.cidade.nome.chomp) == 'Francisco Beltrão'
      param_nome_municipio = {"codigoIbge" => 410840, "nome" => nome}
    else
      param_nome_municipio = {"nome" => nome}
    end
  else
    param_nome_municipio = {"nome" => ""}
  end

  json_aluno = {
    "codigoReferencial" => aluno.id.to_s,
    "nome" => aluno.nome.upcase,
    "nomeFantasia" => "",
    "cpfCnpj" => aluno.cpf.to_s.gsub(/[.-]/, ""),
    "tipo" => "F",
    "sexo" => aluno.sexo,
    "dataNascimento" => aluno.data_nascimento.strftime("%d/%m/%Y"),
    "endereco" => (aluno.endereco.nil?) ? "" : aluno.endereco.logradouro.upcase,
    "numero"=> (aluno.endereco.nil?) ? "" : aluno.endereco.numero,
    "municipio"=> param_nome_municipio,
    "estado"=> { "sigla" => (aluno.endereco.nil? or aluno.endereco.cidade.nil?) ? "" : aluno.endereco.cidade.estado.sigla },
    "cep" => (aluno.endereco.nil? or aluno.endereco.cep.nil?) ? "" : aluno.endereco.cep.gsub(/[.-]/,""),
    "email" => aluno.email.to_s,
    "fone" => begin Telefone.select("(lpad(ddd, 3, '0')||numero) as fone").order(:id).find_by_aluno_id(aluno.id)[:fone].gsub(/[\(\)\/-]/,"").gsub(/\s/,"") rescue "" end,
    "celular" => "",
    "fax" => "",
    "observacoes" => "",
    "bairro" => (aluno.endereco.nil? or aluno.endereco.bairro.nil?) ? "" : aluno.endereco.bairro.nome.chomp.upcase,
    "complemento" => (aluno.endereco.nil? or aluno.endereco.complemento.nil?) ? "" : aluno.endereco.complemento.upcase,
    "dataCadastro" => aluno.created_at.strftime("%d/%m/%Y"),
    "tipoCliente" => true,
    "tipoFornecedor" => false,
    "tipoFuncionario" => false,
    "rgIc" => "",
    "im" => "",
    "cnae" => "",
    "valorSalario" => 0.0,
    "codigoPais" => 1058,
    "nomeParaContato" => ""
  }

  require 'net/http'
  require 'uri'

  url = 'http://sisagil.com/service'
  url = URI.parse(url)
  req = Net::HTTP::Post.new(url.path)
  req.basic_auth 'invent.to.magnus', '123'
  req.set_form_data({'action'=>'save', 'entity'=>'pessoa', 'json' => json_aluno.to_json.to_s})
  res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    if res.body["FAILURE"]
      puts "=== .: FAILURE - Aluno ID #{aluno.id}:. ===", res.body
    else
      puts "=== .: Success :. ==="
    end
  else
    puts res.error!
  end
end
