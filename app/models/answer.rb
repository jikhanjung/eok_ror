class Answer < ApplicationRecord
  belongs_to :interview_question
  has_one_attached :audio_file

  validates :stt_status, presence: true

  enum stt_status: { pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
  
  # Allow setting audio_file via 'audio' parameter
  def audio=(file)
    self.audio_file = file
  end
end