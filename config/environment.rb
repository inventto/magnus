# coding: utf-8
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ControleDePresencaMagnus::Application.initialize!

Time::DATE_FORMATS[:data_nascimento] = "%d/%m/%Y"
Date.const_set 'MONTHNAMES', %w(Dezembro Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro)
Date.const_set 'DAYNAMES',   %w(domingo segunda-feira terça-feira quarta-feira quinta-feira sexta-feira sábado)
Date.const_set 'ABBR_MONTHNAMES', %w(Dez Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov)
Date.const_set 'ABBR_DAYNAMES',   %w(Dom Seg Ter Qua Qui Sex Sab)
