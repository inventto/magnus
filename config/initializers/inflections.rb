# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
   inflect.irregular 'tipo_telefone', 'tipos_telefone'
   inflect.irregular 'horario_de_aula', 'horarios_de_aula'
   inflect.irregular 'justificativa_de_falta', 'justificativas_de_falta'
   inflect.irregular 'registro_de_ponto', 'registros_de_ponto'
   inflect.irregular 'reposicao', 'reposicoes'
end
#
# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.acronym 'RESTful'
# end
