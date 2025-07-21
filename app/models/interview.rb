class Interview < ApplicationRecord
  belongs_to :created_from_template, class_name: 'InterviewTemplate', optional: true
  has_many :interview_questions, dependent: :destroy
  has_many :answers, through: :interview_questions

  validates :interviewee_name, presence: true
  validates :status, presence: true
  validates :unique_link_id, presence: true, uniqueness: true

  enum status: { pending: 'pending', in_progress: 'in_progress', completed: 'completed', expired: 'expired' }

  before_validation :generate_unique_link_id, on: :create

  private

  def generate_unique_link_id
    self.unique_link_id = SecureRandom.hex(10) unless unique_link_id.present?
  end
end