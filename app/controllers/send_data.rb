#coding: utf-8
class SendData
  def send aluno
    if Rails.env.production?
      user = 'invent.to.magnus'
      password = '123'
    else
      #user = 'teste'
      #password = 'teste'
      return true
    end

    @errors = ""
    require 'net/http'
    require 'uri'

    url = 'http://academi.as'
    url = URI.parse(url)

    request = Net::HTTP::Post.new(url.path)
    request.basic_auth user, password
    request.set_form_data({'action'=>'save', 'entity'=>'pessoa', 'json' => get_json_aluno(aluno).to_json.to_s})

    response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
    case response
    when Net::HTTPSuccess, Net::HTTPRedirection
      msg = response.body
      if msg["FAILURE"]
        msg = get_error_message(msg)
        puts "=== .: Erro ao enviar dados ao Sisagil - Aluno ID #{aluno.id}:. ==="
        puts msg
        @errors = msg
      puts "MATRICULA2"+matricula_standby
      else
        puts "=== .: Aluno ID #{aluno.id} Enviado ao Sisagil com Sucesso! :. ==="
      end
    else
      puts response.error!
      @errors = response.error!
    end
    @errors.blank?
  end

  def get_errors
    return @errors
  end

  def get_json_aluno aluno
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
      "endereco" => (aluno.endereco.nil? or aluno.endereco.logradouro.nil?) ? "" : aluno.endereco.logradouro.upcase,
      "numero"=> (aluno.endereco.nil? or aluno.endereco.numero.nil?) ? "" : aluno.endereco.numero,
      "municipio"=> param_nome_municipio,
      "estado"=> { "sigla" => (aluno.endereco.nil? or aluno.endereco.cidade.nil?) ? "" : aluno.endereco.cidade.estado.sigla },
      "cep" => (aluno.endereco.nil? or aluno.endereco.cep.nil?) ? "" : aluno.endereco.cep.gsub(/[.-]/,""),
      "email" => aluno.email.to_s,
      "fone" => begin Telefone.select("(lpad(ddd, 3, '0')||numero) as fone").order(:id).find_by_aluno_id(aluno.id)[:fone].gsub(/[\(\)\/-]/,"").gsub(/\s/,"") rescue "" end,
      "celular" => "",
      "fax" => "",
      "observacoes" => "",
      "bairro" => (aluno.endereco.nil? or aluno.endereco.bairro.nil?) ? "" : aluno.endereco.bairro.nome.upcase,
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
    json_aluno
  end

  def get_error_message msg
    msg = msg.force_encoding("utf-8")
    msg_error = msg.match(/IllegalArgumentException.*/)
    msg_error = msg_error[0]
    msg_error = msg_error.gsub(/IllegalArgumentException:/, "")
    msg_error = msg_error.gsub(/\\u0027/, "").gsub(/\\u003cbr\/\\u003e\\r\\n/, "").gsub(/[\"}]/,"")
    msg_error = msg_error.gsub(/cep /,"")
    msg_error = msg_error.split(/O.objeto.Pessoa/)

    msg_temp = ""
    msg_error.each do |msg|
      msg_temp << msg.gsub(/Ex\..*/,"")
    end

    msg_error = msg_temp.split("-").join("e")
    msg_error = msg_error.gsub(/^\s*e/, "")
    msg_error
  end
end
