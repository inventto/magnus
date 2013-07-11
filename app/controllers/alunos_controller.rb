  #coding: utf-8
class AlunosController < ApplicationController
  active_scaffold :aluno do |conf|
    conf.columns[:endereco].label = "Endereço"
    conf.columns[:cpf].label = "CPF"
    conf.columns[:telefones].label = "Telefone"
    conf.columns[:codigo_de_acesso].label = "Código de Acesso"
    conf.columns = [:id, :foto, :nome, :cpf, :email, :sexo, :data_nascimento, :codigo_de_acesso, :foto, :endereco, :telefones]
    conf.show.columns << :presencas
    conf.show.columns << :pontualidade
    conf.show.columns << :estatisticas
    conf.columns[:data_nascimento].options[:format] = :default
    conf.columns[:sexo].form_ui = :select
    conf.columns[:sexo].options = {:options => Aluno::SEX.map(&:to_sym)}
    conf.columns[:endereco].allow_add_existing = false
    conf.actions.swap :search, :field_search
    conf.field_search.human_conditions = true
    conf.field_search.columns = [:nome, :cpf, :email, :sexo, :data_nascimento]
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

    # Caso o aluno tenha adiantado o horário mas o usuário não tenha lançado no sistema, o sistema irá gerar uma presença fora de horário, após essa ocorrência caso o usuário lance um adiantamento
    # para esse horário deve-se apenas atualizar a presença fora de horário para realocação(nesse caso adiantamento) e criar a falta com justificativa para o horário de aula do dia.
    if data == data_de_realocacao
      presenca_fora_de_horario = Presenca.find_by_aluno_id_and_data_and_fora_de_horario(aluno_id, data, true)
      if not presenca_fora_de_horario.nil?
        if not horario_de_aula.nil?
          if txt_to_seg(presenca_fora_de_horario.horario) < txt_to_seg(horario_de_aula.horario)
            presenca_fora_de_horario.fora_de_horario = false
            presenca_fora_de_horario.realocacao = true
            presenca_fora_de_horario.data_de_realocacao = data_de_realocacao
            presenca_fora_de_horario.save

            p = Presenca.create(:aluno_id => aluno_id, :data => data_de_realocacao, :presenca => false, :horario => horario_de_aula.horario)
            JustificativaDeFalta.create(:presenca_id => p.id, :descricao => "adiantado para o dia #{data.strftime("%d/%m/%Y")} às #{presenca_fora_de_horario.horario}")

            render :text => error and return
          end
        end
      end
    end

    # Criar a falta
    p = Presenca.create(:aluno_id => aluno_id, :data => data_de_realocacao, :presenca => false, :horario => horario_de_aula.horario)
    JustificativaDeFalta.create(:presenca_id => p.id, :descricao => "adiantado para o dia #{data.strftime("%d/%m/%Y")} às #{params[:horario]}")

    # Criar o adiantamento
    Presenca.create(:aluno_id => aluno_id, :presenca => false, :data => data, :realocacao => true, :data_de_realocacao => data_de_realocacao, :horario => params[:horario])

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
      falta = Presenca.joins(:justificativa_de_falta).where("justificativas_de_falta.descricao <> ''")
      falta = falta.find_all_by_aluno_id_and_data_and_presenca_and_tem_direito_a_reposicao(aluno_id, data_de_realocacao, false, true)[0]
      if falta.nil?
        horario_de_aula = HorarioDeAula.do_aluno_pelo_dia_da_semana(aluno_id, data_de_realocacao.wday)[0]
        if not horario_de_aula.nil?
          falta_justificada = Presenca.create(:aluno_id => aluno_id, :data => data_de_realocacao, :presenca => false, :tem_direito_a_reposicao => true, :horario => horario_de_aula.horario)
          JustificativaDeFalta.create(:presenca_id => falta_justificada.id, :descricao => "aula reposta em #{data.strftime("%d/%m/%Y")}")
        else
          note = "Não pôde ser criada a Falta para o dia #{data_de_realocacao.strftime("%d/%m/%Y")}, pois aluno não possui aula nesse dia."
        end
      elsif horario_valido
        if data == data_de_realocacao
          horario_a_ser_reposto = txt_to_seg(falta.horario)
          horario = txt_to_seg(params[:horario])
          if horario <= horario_a_ser_reposto
            error << "<strong>Horário de Reposição</strong> deve ser maior que Horário da Aula a ser Reposta!"
          end
        end
      end
    end
    if not error.blank?
      render :text => error and return
    end

    Presenca.create(:aluno_id => aluno_id, :data => data, :presenca => false, :data_de_realocacao => data_de_realocacao, :horario => params[:horario], :realocacao => true)

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
        presenca = Presenca.create(:aluno_id => aluno_id, :data => data, :horario => aula.horario, :presenca => false, :realocacao => false, :fora_de_horario => false, :tem_direito_a_reposicao => true)
        JustificativaDeFalta.create( :presenca_id => presenca.id, :descricao => params[:justificativa])
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

    render :text => codigo
  end

  def codigo_existe?(codigo)
    if id = params[:id] and not id.blank?
      Aluno.where("id <> ?", id.to_i).find_by_codigo_de_acesso(codigo)
    else
     Aluno.find_by_codigo_de_acesso(codigo)
    end
  end

  def hora_valida?(hora)
    Time.strptime(hora, "%H:%M") rescue false
  end

  def txt_to_seg hour
    Time.strptime(hour, "%H:%M").seconds_since_midnight
  end
end
