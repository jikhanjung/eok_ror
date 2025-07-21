class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers, id: :uuid do |t|
      t.references :interview_question, type: :uuid, null: false, foreign_key: true
      t.string :stt_status, null: false, default: 'pending'
      t.jsonb :transcript_result

      t.timestamps
    end
  end
end
