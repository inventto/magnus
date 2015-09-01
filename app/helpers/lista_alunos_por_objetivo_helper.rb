module ListaAlunosPorObjetivoHelper
  def calcula_porcentagem valor
    ((valor.to_f/@alunos_com_marticula.length) * 100).round(2)
  end
  def valida_objetivo pessoa
    pessoa.matriculas.valida.first.objetivo_secundario.nil? ? "Sem objetivo" : pessoa.matriculas.valida.first.objetivo_secundario
  end
end
