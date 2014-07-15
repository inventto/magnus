#encoding: utf-8
class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attr, value)
    record.errors.add(attr, "Inválido!") if not value.blank? and not cpf_valido?(value)
  end

  DIVISOR = 11

  CPF_LENGTH = 11
  CPF_REGEX = /^(\d{3}\.?\d{3}\.?\d{3})-?(\d{2})$/
  CPF_ALGS_1 = [10, 9, 8, 7, 6, 5, 4, 3, 2]
  CPF_ALGS_2 = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

  def cpf_valido?(cpf)
    @numero = cpf
    @match = @numero =~ CPF_REGEX

    return false unless @match

    @numero_puro = $1
    @para_verificacao = $2
    @numero = (@match ? format_number! : nil)

    verifica_cpf
  end

  def verifica_cpf
    limpo = @numero.gsub(/[\.\/-]/, "")
    return false if limpo.scan(/\d/).uniq.length == 1
    primeiro_verificador = primeiro_digito_verificador
    segundo_verificador = segundo_digito_verificador(primeiro_verificador)
    verif = primeiro_verificador + segundo_verificador
    verif == @para_verificacao
  end

  def multiplica_e_soma(algs, numero_str)
    multiplicados = []
    numero_str.scan(/\d{1}/).each_with_index { |e, i| multiplicados[i] = e.to_i * algs[i] }
    multiplicados.inject { |s,e| s + e }
  end

  def digito_verificador(resto)
    resto < 2 ? 0 : DIVISOR - resto
  end

  def primeiro_digito_verificador
    array = CPF_ALGS_1
    soma = multiplica_e_soma(array, @numero_puro)
    digito_verificador(soma%DIVISOR).to_s
  end

  def segundo_digito_verificador(primeiro_verificador)
    array = CPF_ALGS_2
    soma = multiplica_e_soma(array, @numero_puro + primeiro_verificador)
    digito_verificador(soma%DIVISOR).to_s
  end

  def format_number!
    @numero =~ /(\d{3})\.?(\d{3})\.?(\d{3})-?(\d{2})/
    @numero = "#{$1}.#{$2}.#{$3}-#{$4}"
  end
end
