# -*- encoding : utf-8 -*-
module ListaDeAlunosAtivosInativosHelper
  def com_objetivo_primario(pessoa)
    if pessoa.matriculas
      if pessoa.matriculas.valida.first
        pessoa.matriculas.valida.first.objetivo_primario
      end
    end
  end
end
