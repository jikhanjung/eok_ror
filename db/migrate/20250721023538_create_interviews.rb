class CreateInterviews < ActiveRecord::Migration[7.1]
  def change
    create_table :interviews, id: :uuid do |t|
      t.string :interviewee_name, null: false
      t.string :interviewee_email
      t.string :status, null: false, default: 'pending'
      t.references :created_from_template, type: :uuid, foreign_key: { to_table: :interview_templates }
      t.string :unique_link_id, null: false

      t.timestamps
    end
    add_index :interviews, :unique_link_id, unique: true
  end
end
