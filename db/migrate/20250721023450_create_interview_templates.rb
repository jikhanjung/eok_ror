class CreateInterviewTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :interview_templates, id: :uuid do |t|
      t.string :template_name, null: false
      t.text :description
      t.references :created_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :interview_templates, :template_name, unique: true
  end
end
