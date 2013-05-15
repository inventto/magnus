#coding: utf-8
class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:do_reset_password, :reset_password_edit]

    def reset_password
        id = params[:id]
        if id.nil?
          id = current_user.id
        end    
        if (!user_signed_in? || current_user.id.to_s != id.to_s)
        flash[:alert] = "You don't have that right." 
          redirect_to '/home'
          return
        end

        @user = User.find(id)
        @user.send_reset_password_instructions

        respond_to do |format|
            format.html { redirect_to '/users/edit', notice: 'You will receive an email with instructions about how to reset your password in a few minutes.' }
        end
     end

    def do_reset_password
        id = params[:id]
        if id.nil? && !current_user.nil?
          id = current_user.id
        end

        if id.nil?
          @user = User.where(:reset_password_token => params[:user][:reset_password_token]).first
        else
          @user = User.find(id)
        end
        if  @user.nil? || @user.reset_password_token.to_s != params[:user][:reset_password_token]
          flash[:alert] = "Url to reset was incorrect, please resend reset email." 
          redirect_to '/'
          return
        end
        # there may be a better way of doing this, devise should be able to give us these messages
        if params[:user][:password] != params[:user][:password_confirmation]
          flash[:alert] = "A senhas devem ser iguais!" 
          redirect_to :back
          return
        end
        if @user.reset_password!(params[:user][:password],params[:user][:password_confirmation])
          # @user.hasSetPassword = true
          @user.save
          respond_to do |format|
            format.html { redirect_to '/', notice: 'Senha alterada com sucesso!' }
          end
        else
          flash[:alert] = "Senha Inválida, deve ter mais que 6 caracteres!" 
          redirect_to :back 
        end
    end

    def reset_password_edit
        @user = User.where(:reset_password_token => params[:reset_password_token]).first
        if  @user.nil? || !@user.reset_password_period_valid?
            flash[:alert] = "Período para alterar a senha expirou, por favor faça novo pedido de alteração!" 
            redirect_to "/"
            return
        end
    end
end
