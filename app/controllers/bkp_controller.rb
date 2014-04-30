class BkpController < ApplicationController
  def gerar
    `/var/bkp/scrits/gera_bkp_magnus.sh`
    redirect_to :baixar
  end
  def baixar
    respond_to do |format|
      format.zip { send_file bkp_nome }
    end
  end
  private
  def bkp_nome
    Dir["/var/bkp/magnus/today/*.zip"][0]
  end
end
