class CreateSdKeyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_key_questions do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.references :key_questions_project, foreign_key: true

      t.timestamps
    end
  end
end
