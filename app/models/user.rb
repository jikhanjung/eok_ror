class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :created_interview_templates, class_name: 'InterviewTemplate', foreign_key: 'created_by_id'
  
  # Validations
  validates :preferred_locale, inclusion: { in: %w[ko en] }
  
  # Set default locale if not present
  before_validation :set_default_locale
  
  private
  
  def set_default_locale
    self.preferred_locale ||= 'ko'
  end
end
