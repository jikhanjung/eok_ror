# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
admin_user = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.is_admin = true
end

puts "Admin user created: #{admin_user.email}"

# Create sample interview template
template = InterviewTemplate.find_or_create_by!(template_name: '기본 인생사 인터뷰') do |t|
  t.description = '개인의 인생 경험과 추억을 수집하기 위한 기본 템플릿'
  t.created_by = admin_user
end

# Create sample questions for the template
sample_questions = [
  "자기소개를 해주세요. 언제, 어디서 태어나셨나요?",
  "어린 시절에 대한 기억 중 가장 인상 깊었던 일이 있다면 말씀해 주세요.",
  "학창 시절은 어떠셨나요? 특별히 기억에 남는 선생님이나 친구가 있나요?",
  "첫 직장 생활은 어떠셨나요? 어떤 일을 하셨나요?",
  "결혼과 가정에 대해서 말씀해 주세요.",
  "인생에서 가장 힘들었던 시기는 언제였나요? 어떻게 극복하셨나요?",
  "반대로 가장 행복했던 순간은 언제였나요?",
  "지금의 젊은 세대에게 전하고 싶은 말씀이 있다면?",
  "앞으로의 계획이나 소망이 있으시다면 말씀해 주세요.",
  "마지막으로 하고 싶은 말씀이 있으시다면?"
]

sample_questions.each_with_index do |question_text, index|
  template.template_questions.find_or_create_by!(display_order: index) do |q|
    q.question_text = question_text
    q.estimated_time_seconds = 300 # 5 minutes
  end
end

puts "Sample template created with #{template.template_questions.count} questions"
