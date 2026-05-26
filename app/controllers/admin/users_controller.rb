class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i[ show edit update ]

  def index
    @users = User.order(:name)
    @users = @users.where(role: params[:role]) if params[:role].present?

    if (q = params[:q].to_s.strip).present?
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
      @users = @users.where("name LIKE :p OR handle LIKE :p", p: pattern)
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      flash.now[:alert] = form_error_message(@user)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: %i[ name handle email_address role status ])
    end
end
