class UsersController < ApplicationController
  before_action :fetch_user

  def new
    @user = User.new
  end

  def create
    user = User.create user_params

    if user.persisted?
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash[:errors] = user.errors.full_messages
      redirect_to new_user_path
    end
  end

  def show
    @user = User.find params[:id]
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]

    unless @user == @current_user
      redirect_to user_path(@current_user)
      return
    end

    if @user.update(user_params)
      return
      redirect_to root_path
    else
      flash[:errors] = @user.errors.full_messages
      render :edit
    end
  end

  def gallery
    # Ensures only logged-in users can get to the user's gallery page
    unless @current_user.present?
      redirect_to login_path
      return
    end

    @drawings = User.find_by(id: @current_user).drawings
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
