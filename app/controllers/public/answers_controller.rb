class Public::AnswersController < ApplicationController
  before_action :set_interview
  before_action :set_interview_question, only: [:create]

  def create
    @answer = @interview_question.build_answer(answer_params)

    if @answer.save
      # Start transcription job
      TranscribeAudioJob.perform_later(@answer.id) if @answer.audio_file.attached?
      
      render json: { status: 'success', message: 'Answer submitted successfully' }
    else
      render json: { status: 'error', errors: @answer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_interview
    @interview = Interview.find_by!(unique_link_id: params[:interview_unique_link_id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'error', message: 'Interview not found' }, status: :not_found
  end

  def set_interview_question
    # Handle both params[:interview_question_id] and params[:answer][:interview_question_id]
    question_id = params[:interview_question_id] || params.dig(:answer, :interview_question_id)
    @interview_question = @interview.interview_questions.find(question_id)
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'error', message: 'Question not found' }, status: :not_found
  end

  def answer_params
    # Handle both audio and audio_file parameter names
    params.require(:answer).permit(:audio_file, :audio)
  end
end