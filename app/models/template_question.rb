class TemplateQuestion < ApplicationRecord
  belongs_to :interview_template

  validates :question_text, presence: true
  validates :display_order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :display_order, uniqueness: { scope: :interview_template_id }

  default_scope { order(:display_order) }
end