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
    # users that are created by the current user and current user
    @users = User.where(created_by: current_user.id).or(User.where(id: current_user.id))
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :username, :created_by)
  end

end