class BkpController < ApplicationController
  def gerar
    `sh /var/bkp/scripts/gera_bkp_magnus.sh`
    baixar
  end

  def baixar
      send_file(bkp_nome, diposition: 'inline')
  end

  private
  def bkp_nome
    Dir["/var/bkp/magnus/today/*.zip"].first
  end
end
