class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.references :question_type, foreign_key: true
      t.references :extraction_forms_projects_section, foreign_key: true
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :questions, :deleted_at
    add_index :questions, [:question_type_id, :extraction_forms_projects_section_id, :deleted_at], name: 'index_q_on_qt_id_efps_id_deleted_at', where: 'deleted_at IS NULL'
  end
end
