# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :authorize_admin, only: [:new, :create]


  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to authenticated_root_path
    else
      render :new
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password,:password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password)
    end

    def authorize_admin
      if current_user.nil? 
        redirect_to unauthenticated_root_path
      elsif
        current_user.role != "admin"
        redirect_to unauthenticated_root_path
      end
    end
  

end
