class CreateTemplateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :template_questions, id: :uuid do |t|
      t.references :interview_template, type: :uuid, null: false, foreign_key: true
      t.text :question_text, null: false
      t.integer :display_order, null: false
      t.integer :estimated_time_seconds

      t.timestamps
    end
    add_index :template_questions, [:interview_template_id, :display_order], unique: true
  end
end
