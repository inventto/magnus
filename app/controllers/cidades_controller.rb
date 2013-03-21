class CidadesController < ApplicationController
  active_scaffold :cidade do |conf|
    conf.columns.exclude :bairros
  end
end
