class UsersController < ApplicationController
  def edit
  end

  def update
    if Current.user.update(user_params)
      respond_to do |format|
        format.html { redirect_to profile_path, notice: "Profile updated." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = form_error_message(Current.user)
          render :edit, status: :unprocessable_entity
        end
        format.json { head :unprocessable_entity }
      end
    end
  end

  def destroy
    user = Current.user

    if params[:confirm_handle].to_s.strip.downcase != user.handle.downcase
      redirect_to profile_path, alert: "Type your handle to confirm deletion."
      return
    end

    user.sessions.destroy_all
    cookies.delete(:session_id)
    user.destroy
    redirect_to new_session_path, notice: "Your account has been deleted. Goodbye."
  end

  private
    def user_params
      params.expect(user: [ :name, :handle, :email_address, :theme, :accent, :time_zone ])
    end
end
