#encoding: utf-8
class ContatosController < ApplicationController
  def new
    @pessoa = Pessoa.find(params[:pessoa_id])
  end
  def create
    if  params[:contato][:descricao].blank?
       flash[:error] = "<strong>Campo Descrição</strong> não pode ficar vazio!\n"
    end

   if  params[:contato][:data].blank?
      flash[:error] << "<strong>Campo Data</strong> não pode ficar vazio!\n"
   end

    Contato.create(:descricao => params[:contato][:descricao], :data_contato => params[:contato][:data], :pessoa_id => params["pessoa_id"])
    redirect_to "/historico_contatos"
  end

  def index
    @contatos = Contato.joins(:pessoa).where(pessoa_id: params[:pessoa_id])
  end

  def destroy
    contato = Contato.por_id(params[:id]).first
    contato.destroy
    redirect_to :action => 'index'
  end

  def edit
      @contato = Contato.por_id(params[:id]).first
  end

  def update
      contato = Contato.por_id(params[:id])
      if contato.update(params[:id], :descricao => params[:descricao], :data_contato => params[:contato][:data])
      redirect_to :action => 'index'
      else
      redirect_to :action => 'edit'
      end
  end
end
