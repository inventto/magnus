#encoding: utf-8
class ListaAlunosPorObjetivoController < ApplicationController
  def index
    @alunos_com_marticula = Pessoa.joins(:matriculas).where("(matriculas.data_fim > ? or matriculas.data_fim is null)", Time.now).order(:nome)
    alunos_com_objetivo_perda_de_peso
    alunos_com_objetivo_qualidade_de_vida
    alunos_com_condicionamento_fisico
    alunos_com_definicao_muscular
    alunos_com_hipertrofia
    alunos_com_objetivo_tonicidade
    sem_objetivos_primarios
  end

  def alunos_com_objetivo_perda_de_peso
    @objetivos_perda_de_peso ||= []
    @objetivos_perda_de_peso = alunos_com_objetivo_primario("Perda de Peso")
  end

  def alunos_com_objetivo_qualidade_de_vida
    @objetivos_com_qualidade_de_vida ||= []
    @objetivos_com_qualidade_de_vida = alunos_com_objetivo_primario("Qualidade de vida")
  end

  def alunos_com_condicionamento_fisico
    @objetivos_com_condicionamento_fisico ||= [] 
    @objetivos_com_condicionamento_fisico = alunos_com_objetivo_primario("Condicionamento Físico")
  end

  def alunos_com_definicao_muscular
    @objetivos_com_deifinicao_muscular ||= []
    @objetivos_com_deifinicao_muscular = alunos_com_objetivo_primario("Definição Muscular")
  end

  def alunos_com_hipertrofia
    @objetivos_com_hipertrofia ||= []
    @objetivos_com_hipertrofia = alunos_com_objetivo_primario("Hipertrofia")
  end

  def alunos_com_objetivo_tonicidade
    @objetivos_com_tonicidade ||= []
    @objetivos_com_tonicidade = alunos_com_objetivo_primario("Tonicidade")
  end

  def sem_objetivos_primarios
   @sem_objetivos_primarios ||= [] 
   @sem_objetivos_primarios = alunos_com_objetivo_primario(nil)
  end

  def alunos_com_objetivo_primario(objetivo)
    alunos = []
    @alunos_com_marticula.collect do |pessoa|
      if pessoa.matriculas.valida.first
        if pessoa.matriculas.valida.first.objetivo_primario.eql?(objetivo)
          alunos << pessoa
        end
      end
    end
    return alunos
  end
end
