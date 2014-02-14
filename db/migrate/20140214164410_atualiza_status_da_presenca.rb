class Presenca < ActiveRecord::Base
  has_one :justificativa_de_falta

  def categorizar!
    conditions = {realocacao: realocacao?,
                 presenca:  presenca?,
                 aula_extra: aula_extra?,
                 direito_reposicao: tem_direito_a_reposicao?,
                 justificavel: tem_direito_a_reposicao? || !justificativa_de_falta.nil? }
    scope = StatusPresenca.where(conditions)
    if found = scope.first
      self.status_presenca_id = found.id
    else
      if conditions[:justificavel]
        conditions[:justificavel] = false
        found = StatusPresenca.where(conditions).first
      end
      if not found
        if justificativa_de_falta and not presenca? 
          found = StatusPresenca.falta.justificavel.first
        elsif presenca? and not aula_extra? and not tem_direito_a_reposicao?
          found = StatusPresenca.presenca.where(aula_extra:false, realocacao: false).first
        end
      end

      if not found
        p conditions, pontualidade, data, justificativa_de_falta, " - "
      else
        self.status_presenca_id = found.id
      end
    end
    save
  end
end
class AtualizaStatusDaPresenca < ActiveRecord::Migration
  def up 
    change_table :presencas do |t|
      t.references :status_presenca
    end

    JustificativaDeFalta.all.select{|e| e.destroy if e.descricao.blank?  }
    Presenca.all.each do |presenca|
      presenca.categorizar!
    end

    #remove_column :presencas, :status_presenca_id
  end
  def down
    remove_column :presencas, :status_presenca_id
  end
end
