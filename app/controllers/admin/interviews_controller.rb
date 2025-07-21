class Admin::InterviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_interview, only: [:show, :edit, :update, :destroy, :transcribe_answer]

  def index
    @interviews = Interview.includes(:created_from_template, :interview_questions, :answers).order(created_at: :desc)
  end

  def show
    @interview_questions = @interview.interview_questions.includes(:answer)
  end

  def new
    @interview = Interview.new
    @templates = InterviewTemplate.order(:template_name)
  end

  def create
    @interview = Interview.new(interview_params)

    if @interview.save
      copy_template_questions if @interview.created_from_template.present?
      redirect_to admin_interview_path(@interview), notice: 'Interview was successfully created.'
    else
      @templates = InterviewTemplate.order(:template_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @interview.update(interview_params)
      redirect_to admin_interview_path(@interview), notice: 'Interview was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @interview.destroy
    redirect_to admin_interviews_path, notice: 'Interview was successfully deleted.'
  end

  def transcribe_answer
    answer = Answer.find(params[:answer_id])
    TranscribeAudioJob.perform_later(answer.id)
    redirect_to admin_interview_path(@interview), notice: 'Transcription started.'
  end

  private

  def set_interview
    @interview = Interview.find(params[:id])
  end

  def interview_params
    params.require(:interview).permit(:interviewee_name, :interviewee_email, :created_from_template_id)
  end

  def copy_template_questions
    @interview.created_from_template.template_questions.each do |template_question|
      @interview.interview_questions.create!(
        question_text: template_question.question_text,
        display_order: template_question.display_order
      )
    end
  end

  def ensure_admin
    redirect_to root_path unless current_user&.is_admin?
  end
end