class TranscribeAudioJob < ApplicationJob
  queue_as :default

  def perform(answer_id)
    answer = Answer.find_by(id: answer_id)
    return unless answer && answer.audio_file.attached? && answer.pending?

    answer.processing!

    begin
      # Call external STT service
      stt_service = SttService.new
      audio_url = Rails.application.routes.url_helpers.rails_blob_url(answer.audio_file)
      response = stt_service.transcribe(audio_url, answer_id: answer.id)

      # For now, simulate success/failure
      if rand(10) > 1 # Simulate 90% success rate
        answer.update!(stt_status: :completed, transcript_result: { text: "Simulated transcript for answer #{answer.id}", words: [] })
      else
        answer.failed!
      end

    rescue StandardError => e
      answer.failed!
      Rails.logger.error "STT transcription failed for Answer #{answer_id}: #{e.message}"
    end
  end
end