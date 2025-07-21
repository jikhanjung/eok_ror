class HomeController < ApplicationController
  def index
    if user_signed_in? && current_user.is_admin?
      redirect_to admin_root_path
    end
  end
end
