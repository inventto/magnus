# -*- encoding : utf-8 -*-
class CidadesController < ApplicationController
  autocomplete :bairro, :nome
  active_scaffold :cidade do |conf|
    conf.columns.exclude :bairros
  end
end
