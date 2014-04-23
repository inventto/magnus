module RegistrosDePontoHelper
  def options_for_association_conditions(association)
    if association.active_record == RegistroDePonto and association.name == :pessoa
      'pessoas.tipo_de_pessoa > 0'
    else
      super
    end
  end
end
