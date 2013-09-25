class ClientesInativosController < ApplicationController
  def index
    @matriculas = Matricula.where("data_fim is not null")
  end

  def filtrar
    @matriculas = Matricula.where("data_fim is not null")

    all_blank = true
    if aluno_id = params["aluno_id"] and not aluno_id.blank?
      @matriculas = @matriculas.where(:pessoa_id => aluno_id.to_i)
      all_blank = false
    end
    if dias_da_semana = params["dias_da_semana"] and not dias_da_semana.blank?
      dias = []
      dias = dias_da_semana.split(",")
      @matriculas = @matriculas.where("matriculas.id IN (SELECT matricula_id FROM horarios_de_aula WHERE dia_da_semana IN (?) GROUP BY matricula_id)", dias)
      all_blank = false
    elsif freq_semanal = params["freq_semanal"] and not freq_semanal.blank?
      mats = Matricula.select("count(dia_da_semana), matricula_id").joins(:horario_de_aula).group(:matricula_id).having("count(dia_da_semana) = ?", freq_semanal.to_i)
      if not mats.blank?
        matriculas_id = []
        mats.each {|m| matriculas_id << m.matricula_id }
      end
      @matriculas = @matriculas.where("id IN (?)", matriculas_ids)
      all_blank = false
    end
    if mes_da_interrupcao = params["mes_da_interrupcao"] and not mes_da_interrupcao.blank?
      mes_da_interrupcao = (mes_da_interrupcao.to_i == 0) ? 12 : mes_da_interrupcao.to_i
      @matriculas = @matriculas.where("EXTRACT(MONTH FROM data_fim) = ?", mes_da_interrupcao)
      all_blank = false
    end
    if tipo_do_tempo = params["tipo_do_tempo"] and not tipo_do_tempo.blank?
      if tempo_de_permanencia = params["tempo_de_permanencia"] and not tempo_de_permanencia.blank?
        if tipo_do_tempo == "dia"
          cond = "data_fim - data_inicio"
        elsif tipo_do_tempo == "mes"
          cond = "(data_fim - data_inicio) / 30"
        else
          cond = "(data_fim - data_inicio) / 365"
        end
        @matriculas = @matriculas.where("#{cond} <= ?", tempo_de_permanencia.to_i)
        all_blank = false
      end
    end

    if all_blank
      redirect_to "/clientes_inativos"
    else
      render "/clientes_inativos/index"
    end
  end
end
