class Admin::InterviewTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_interview_template, only: [:show, :edit, :update, :destroy]

  def index
    @interview_templates = InterviewTemplate.includes(:template_questions).order(:template_name)
  end

  def show
  end

  def new
    @interview_template = InterviewTemplate.new
    @interview_template.template_questions.build
  end

  def create
    @interview_template = InterviewTemplate.new(interview_template_params)
    @interview_template.created_by = current_user

    if @interview_template.save
      redirect_to admin_interview_template_path(@interview_template), notice: 'Template was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @interview_template.update(interview_template_params)
      redirect_to admin_interview_template_path(@interview_template), notice: 'Template was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @interview_template.destroy
    redirect_to admin_interview_templates_path, notice: 'Template was successfully deleted.'
  end

  private

  def set_interview_template
    @interview_template = InterviewTemplate.find(params[:id])
  end

  def interview_template_params
    params.require(:interview_template).permit(:template_name, :description,
      template_questions_attributes: [:id, :question_text, :display_order, :estimated_time_seconds, :_destroy])
  end

  def ensure_admin
    redirect_to root_path unless current_user&.is_admin?
  end
end