class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @templates_count = InterviewTemplate.count
    @interviews_count = Interview.count
    @recent_interviews = Interview.order(created_at: :desc).limit(5)
  end

  private

  def ensure_admin
    redirect_to root_path unless current_user&.is_admin?
  end
end