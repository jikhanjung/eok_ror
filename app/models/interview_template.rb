class InterviewTemplate < ApplicationRecord
  has_many :template_questions, dependent: :destroy
  belongs_to :created_by, class_name: 'User', optional: true
  has_many :interviews, foreign_key: 'created_from_template_id', dependent: :nullify

  validates :template_name, presence: true, uniqueness: true

  accepts_nested_attributes_for :template_questions, allow_destroy: true
end