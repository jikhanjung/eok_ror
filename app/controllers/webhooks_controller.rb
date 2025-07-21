class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stt_callback
    payload = JSON.parse(request.body.read)
    answer_id = payload['answer_id']
    transcript_data = payload['transcript_data']

    answer = Answer.find_by(id: answer_id)

    if answer
      answer.update!(stt_status: :completed, transcript_result: transcript_data)
      head :ok
    else
      Rails.logger.warn "STT Webhook: Answer with ID #{answer_id} not found."
      head :not_found
    end
  rescue JSON::ParserError => e
    Rails.logger.error "STT Webhook: Invalid JSON payload: #{e.message}"
    head :bad_request
  rescue StandardError => e
    Rails.logger.error "STT Webhook: Error processing callback: #{e.message}"
    head :internal_server_error
  end
end