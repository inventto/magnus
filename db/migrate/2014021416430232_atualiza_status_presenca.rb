class AtualizaStatusPresenca < ActiveRecord::Migration
  def up
    StatusPresenca.presenca.create(descricao: "Presença")
    StatusPresenca.falta.create(descricao: "Falta")
    StatusPresenca.falta.justificavel.create(descricao: "Falta justificada")
    StatusPresenca.falta.justificavel.direito_reposicao.create(descricao: "Falta com direito reposição")
    StatusPresenca.falta.aula_extra.create(descricao: "Aula extra não realizada")
    StatusPresenca.presenca.aula_extra.create(descricao: "Aula extra")
    StatusPresenca.falta.realocacao.create(descricao: "Realocação não realizada")
    StatusPresenca.presenca.realocacao.create(descricao: "Realocação")
  end

  def down
  end
end
