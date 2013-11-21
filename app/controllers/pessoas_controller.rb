  #coding: utf-8
class PessoasController < ApplicationController
  skip_before_filter :authenticate_user!

  active_scaffold :pessoa do |conf|
    conf.columns[:endereco].label = "Endereço"
    conf.columns[:cpf].label = "CPF"
    conf.columns[:telefones].label = "Telefone"
    conf.columns[:codigo_de_acesso].label = "Código de Acesso"
    conf.columns[:e_funcionario].label = "É Funcionário?"
    conf.columns = [:id, :foto, :nome, :cpf, :email, :sexo, :data_nascimento, :e_funcionario, :codigo_de_acesso, :foto, :endereco, :telefones]
    conf.show.columns << :presencas
    conf.show.columns << :aulas
    conf.show.columns << :pontualidade
    conf.show.columns << :estatisticas
    conf.columns[:data_nascimento].options[:format] = :default
    conf.columns[:sexo].form_ui = :select
    conf.columns[:sexo].options = {:options => Pessoa::SEX.map(&:to_sym)}
    conf.columns[:endereco].allow_add_existing = false
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:nome, :cpf, :email, :sexo, :data_nascimento, :e_funcionario]
  end

  def after_update_save record
    send_data_to_sisagil(record)
  end

  def after_create_save record
    send_data_to_sisagil(record)
  end

  def send_data_to_sisagil aluno
    data = SendData.new
    if data.send(aluno)
      flash[:info] = "Aluno #{aluno.nome} enviado ao Sisagil com sucesso!"
    else
      flash[:error] = "Não foi possível enviar dados ao Sisagil do aluno #{aluno.nome}: " << data.get_errors
    end
  end

  def before_update_save record
    set_bairro(record)
  end

  def before_create_save record
    set_bairro(record)
  end

  def set_bairro record
     bairro = Bairro.find_by_nome_and_cidade_id(params[:bairro_nome], record.endereco.cidade_id)
     if bairro.nil?
       bairro = Bairro.create :nome => params[:bairro_nome], :cidade_id => record.endereco.cidade_id
     end
     record.endereco.bairro = bairro
  end


  def gravar_realocacao
    if params[:tipo_realocacao].to_s == "A" # adiantamento
      adiantar_aula
    else # reposição
      gravar_reposicao
    end
  end

  def adiantar_aula
    error = ""

    aluno_id = params[:aluno_id].to_i
    horario_valido = true

    if params[:data].blank?
      error << "<strong>Campo Data</strong> não pode ficar vazio!\n"
    end
    if params[:horario].blank?
      horario_valido = false
      error << "<strong>Horário da Aula</strong> não pode ficar vazio!\n"
    elsif not hora_valida?(params[:horario])
      horario_valido = false
      error << "<strong>Horário da Aula</strong> Inválido!\n"
    end
    if params[:data_de_realocacao].blank?
      error << "<strong>Data do Horário a ser Adiantado</strong> não pode ficar vazio!\n"
    else
      data_de_realocacao = params[:data_de_realocacao].to_date
      horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(aluno_id, data_de_realocacao.wday)[0]

      if horario_de_aula.nil?
        error << "Aluno não possui horário cadastrado para o data de #{data_de_realocacao.strftime("%d/%m/%Y")}"
      elsif horario_valido
        if params[:data].to_date == data_de_realocacao
          horario_a_ser_adiantado = txt_to_seg(horario_de_aula.horario)
          horario = txt_to_seg(params[:horario])
          if horario >= horario_a_ser_adiantado
            error << "<strong>Horário de Adiantamento</strong> deve ser menor que Horário da Aula a ser Adiantada!"
          end
        end
      end
    end
    if not error.blank?
      render :text => error and return
    end

    data = params[:data].to_date
    data_de_realocacao = params[:data_de_realocacao].to_date

    # Criar a falta
    falta = Presenca.create(:pessoa_id => aluno_id, :data => data_de_realocacao, :presenca => false, :horario => horario_de_aula.horario, :tem_direito_a_reposicao => true)
    falta.build_justificativa_de_falta(:descricao => "adiantado para o dia #{data.strftime("%d/%m/%Y")} às #{params[:horario]}")
    falta.save

    # Criar o adiantamento
    Presenca.create(:pessoa_id => aluno_id, :presenca => false, :data => data, :realocacao => true, :data_de_realocacao => data_de_realocacao, :horario => params[:horario])

    render :text => error
  end

  def gravar_reposicao
    error = ""
    note = ""
    horario_valido = true

    aluno_id = params[:aluno_id].to_i

    if params[:data].blank?
      error << "<strong>Campo Data</strong> não pode ficar vazio!\n"
    end
    if params[:horario].blank?
      horario_valido = false
      error << "<strong>Horário da Aula</strong> não pode ficar vazio!\n"
    elsif not hora_valida?(params[:horario])
      horario_valido = false
      error << "<strong>Horário da Aula</strong> Inválido!\n"
    end

    data = params[:data].to_date
    data_de_realocacao = (params[:data_de_realocacao].blank?) ? nil : params[:data_de_realocacao].to_date
    if not data_de_realocacao.nil?
      #falta = Presenca.joins(:justificativa_de_falta).where("justificativas_de_falta.descricao <> ''")
      #falta = falta.find_all_by_pessoa_id_and_data_and_presenca_and_tem_direito_a_reposicao(aluno_id, data_de_realocacao, false, true)[0]
      falta = Presenca.where(:pessoa_id => aluno_id, :data => data_de_realocacao).where("coalesce(presenca, false) = false")[0]
      if falta.nil?
        horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(aluno_id, data_de_realocacao.wday)[0]
        if not horario_de_aula.nil?
          falta_justificada = Presenca.create(:pessoa_id => aluno_id, :data => data_de_realocacao, :presenca => false, :tem_direito_a_reposicao => true, :horario => horario_de_aula.horario)
          falta_justificada.build_justificativa_de_falta(:descricao => "aula reposta em #{data.strftime("%d/%m/%Y")}")
          falta_justificada.save
        else
          note = "Não pôde ser criada a Falta para o dia #{data_de_realocacao.strftime("%d/%m/%Y")}, pois aluno não possui aula nesse dia."
        end
      elsif horario_valido
        puts "== horario valido"
        if data == data_de_realocacao
          puts "== datas iguais"
          horario_a_ser_reposto = txt_to_seg(falta.horario)
          horario = txt_to_seg(params[:horario])
          if horario <= horario_a_ser_reposto
            error << "<strong>Horário de Reposição</strong> deve ser maior que Horário da Aula a ser Reposta!"
          else
            if not falta.tem_direito_a_reposicao
              falta.tem_direito_a_reposicao = true
            end
            if falta.justificativa_de_falta.nil?
              falta.build_justificativa_de_falta(:descricao => "aula reposta às #{params[:horario]}")
            else
              falta.justificativa_de_falta.descricao = "aula reposta às #{params[:horario]}"
            end
            falta.justificativa_de_falta.save
            falta.save
          end
        end
      end
    end
    if not error.blank?
      render :text => error and return
    end

    Presenca.create(:pessoa_id => aluno_id, :data => data, :presenca => false, :data_de_realocacao => data_de_realocacao, :horario => params[:horario], :realocacao => true)

    error << note
    render :text => error
  end

  def justificar_falta
    error = ""

    if params[:justificativa].blank?
      error << "<strong>Justificativa</strong> não pode ficar vazio!"
    end
    if not error.blank?
      render :text => error and return
    end
    data = Date.parse(params[:data_da_falta])
    data_fim =  (params[:data_da_falta_fim].blank?) ? data : Date.parse(params[:data_da_falta_fim])
    aluno_id = params[:aluno_id].to_i
    while (data <= data_fim)
      aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(aluno_id, data.wday)
      if not aula.blank?
        aula = aula[0]
        if not (presenca = Presenca.where(:pessoa_id => aluno_id, :data => data, :horario => aula.horario, :presenca => false)).blank?
          presenca = presenca.first
          presenca.tem_direito_a_reposicao = true
          presenca.build_justificativa_de_falta(:descricao => params[:justificativa])
          presenca.justificativa_de_falta.save
          presenca.save
        else
          falta = Presenca.create(:pessoa_id => aluno_id, :data => data, :horario => aula.horario, :presenca => false, :realocacao => false, :tem_direito_a_reposicao => true)
          falta.build_justificativa_de_falta(:descricao => params[:justificativa])
          falta.save
        end
      end
      data += 1.day
    end

    render :text => error
  end

  def gerar_codigo_de_acesso
    codigo = ""

    if data = params[:nascimento] and not data.blank?
      codigo = data[0..1] << data[3..4] << data[8..9]
      while(codigo_existe?(codigo))
        codigo << codigo[codigo.length - 1]
      end
    end
    eh_funcionario = params[:eh_funcionario]
    codigo = "9" << codigo if eh_funcionario.to_i == 1
    render :text => codigo
  end

  def codigo_existe?(codigo)
    if id = params[:id] and not id.blank?
      Pessoa.where("id <> ?", id.to_i).find_by_codigo_de_acesso(codigo)
    else
     Pessoa.find_by_codigo_de_acesso(codigo)
    end
  end

  def hora_valida?(hora)
    Time.strptime(hora, "%H:%M") rescue false
  end

  def txt_to_seg hour
    Time.strptime(hour, "%H:%M").seconds_since_midnight
  end

  def registros_de_ponto_por_mes
    id = params[:funcionario_id].to_i
    mes = (params[:mes].to_i == 0) ? 12 : params[:mes].to_i # pois Dezembro é o index zero do array
    data_inicio = Date.new(Date.today.year, mes, 1)
    data_fim = data_inicio.at_end_of_month

    @registros_de_ponto = RegistroDePonto.where(:pessoa_id => id)
    @registros_de_ponto = @registros_de_ponto.where("data BETWEEN ? AND ?", data_inicio, data_fim).order("data desc")

    render :partial => "registros_de_ponto_por_mes"
  end

  def get_codigo_do_bairro
    if params and params["nome"]
      bairro = Bairro.where("nome ILIKE '%#{params['nome']}%'")
    end
    nome = (bairro.blank?) ? "" : bairro[0].nome
    render :text => nome
  end

  def get_codigo_da_cidade
    if params and params["nome"]
      cidade = Cidade.where("nome ILIKE '%#{params['nome']}%'")
    end
    id = (cidade.blank?) ? 0 : cidade.first.id
    render :text => id
  end

  def alunos_xml
    pessoas = Pessoa.where(["id > ?", params["id"]||0]).collect do |p|
      export_xml_data p
    end
    render :xml => {alunos: pessoas}.to_xml
  end

  def export_xml_data pessoa
    {"id" => pessoa.id , "nome" => pessoa.nome, "codigo" => pessoa.codigo_de_acesso}
  end

end
