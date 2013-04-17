class BairrosController < ApplicationController
  active_scaffold :bairro do |conf|
    conf.columns[:cidade].form_ui = :select
  end
end
