class Public::InterviewsController < ApplicationController
  before_action :set_interview, only: [:show]

  def show
    case @interview.status
    when 'pending', 'in_progress'
      @interview_questions = @interview.interview_questions.includes(:answer)
    when 'completed'
      render :completed
    when 'expired'
      render :expired
    end
  end

  private

  def set_interview
    @interview = Interview.find_by!(unique_link_id: params[:unique_link_id])
  rescue ActiveRecord::RecordNotFound
    render :not_found, status: :not_found
  end
end