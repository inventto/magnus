class EstadosController < ApplicationController
  active_scaffold :estado do |conf|
    conf.columns.exclude :cidades
  end
end
