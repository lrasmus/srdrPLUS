class KeyQuestionType < ApplicationRecord
  has_many :key_questions_projects, inverse_of: :key_question_type

  include SharedQueryableMethods
end