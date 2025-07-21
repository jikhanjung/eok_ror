class Admin::AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  
  def show
    @user = current_user
  end
  
  def update
    @user = current_user
    
    # Check if we're changing password
    changing_password = account_params[:password].present?
    
    if changing_password
      # Use update_with_password for password changes
      if @user.update_with_password(account_params)
        # Update session locale if it was changed
        session[:locale] = @user.preferred_locale
        I18n.locale = @user.preferred_locale
        
        # Sign in the user to bypass Devise's automatic sign out on password change
        bypass_sign_in(@user)
        
        redirect_to admin_account_path, notice: t('messages.updated')
      else
        render :show, status: :unprocessable_entity
      end
    else
      # For non-password updates, just update without current password
      filtered_params = account_params.except(:password, :password_confirmation, :current_password)
      
      if @user.update(filtered_params)
        # Update session locale if it was changed
        session[:locale] = @user.preferred_locale
        I18n.locale = @user.preferred_locale
        
        redirect_to admin_account_path, notice: t('messages.updated')
      else
        render :show, status: :unprocessable_entity
      end
    end
  end
  
  private
  
  def account_params
    params.require(:user).permit(:email, :preferred_locale, :password, :password_confirmation, :current_password)
  end
  
  def ensure_admin!
    redirect_to root_path unless current_user&.is_admin?
  end
end