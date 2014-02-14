class StatusPresenca < ActiveRecord::Base
  attr_accessible :aula_extra, :descricao, :direito_reposicao, :icone, :justificavel, :presenca, :realocacao
  scope :falta, where(presenca:  false)
  scope :presenca, where(presenca:  true)
  scope :justificavel, where(justificavel: true)
  scope :aula_extra, where(aula_extra: true)
  scope :realocacao, where(realocacao: true)
  scope :direito_reposicao, where(direito_reposicao: true)

end
