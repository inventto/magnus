# -*- encoding : utf-8 -*-
module ClientesGanhamosEPerdemosHelper
  def count_alunos_que_entraram_no(mes,ano,count_alunos)
    @total_alunos_que_entraram[ano] += count_alunos
  end
end
