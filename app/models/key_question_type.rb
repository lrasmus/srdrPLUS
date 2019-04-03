class KeyQuestionType < ApplicationRecord
  include SharedQueryableMethods

  has_many :key_questions_projects, inverse_of: :key_question_type

  has_many :sd_key_questions_key_question_types, inverse_of: :key_question_type
  has_many :sd_key_questions, through: :sd_key_questions_key_question_types
end