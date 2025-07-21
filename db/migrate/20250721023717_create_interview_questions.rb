class CreateInterviewQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :interview_questions, id: :uuid do |t|
      t.references :interview, type: :uuid, null: false, foreign_key: true
      t.text :question_text, null: false
      t.integer :display_order, null: false

      t.timestamps
    end
    add_index :interview_questions, [:interview_id, :display_order], unique: true
  end
end
