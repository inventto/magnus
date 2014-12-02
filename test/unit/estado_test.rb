# -*- encoding : utf-8 -*-
require 'test_helper'

class EstadoTest < ActiveSupport::TestCase
  fixtures :estados
  test "nao salva sem nome e nem sem sigla" do
    estado = Estado.create
    assert_error_on estado, :nome
  end
  test "nao salva nome ou sigla repetida" do
    sc = Estado.create estados(:sc)
    assert_error_on estado, :nome
    assert_error_on estado, :sigla
  end
end
