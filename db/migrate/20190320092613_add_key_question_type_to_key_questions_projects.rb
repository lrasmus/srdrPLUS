class AddKeyQuestionTypeToKeyQuestionsProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :key_questions_projects, :key_question_type, foreign_key: true, type: :integer
  end
end
