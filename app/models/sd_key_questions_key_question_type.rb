class SdKeyQuestionsKeyQuestionType < ApplicationRecord
  include SharedProcessTokenMethods

  belongs_to :sd_key_question, inverse_of: :sd_key_questions_key_question_types
  belongs_to :key_question_type, inverse_of: :sd_key_questions_key_question_types
end
