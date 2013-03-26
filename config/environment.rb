# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ControleDePresencaMagnus::Application.initialize!

Time::DATE_FORMATS[:data_nascimento] = "%d/%m/%Y"
