class Admin::UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        redirect_to accounts_path
      else
        format.turbo_stream { render partial: "admin/users/form_update", status: :unprocessable_entity }
      end
    end
  end

  def accounts
    @users = User.all
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :kind, :username)
  end

end