module RegistrosDePontoHelper
  def options_for_association_conditions(association)
    if association.active_record == RegistroDePonto and association.name == :pessoa
      {'pessoas.e_funcionario' => true}
    else
      super
    end
  end
end
