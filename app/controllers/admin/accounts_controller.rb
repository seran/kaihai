class Admin::AccountsController < Admin::BaseController
  def edit
    @account = Current.account
  end

  def update
    if Current.account.update(account_params)
      redirect_to edit_admin_account_path, notice: "Account updated."
    else
      @account = Current.account
      flash.now[:alert] = form_error_message(@account)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def account_params
      params.expect(account: %i[ name tagline ])
    end
end
