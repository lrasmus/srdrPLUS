class SdKeyQuestionsProject < ApplicationRecord
  belongs_to :sd_key_question, inverse_of: :sd_key_questions_projects
  belongs_to :key_questions_project, inverse_of: :sd_key_questions_projects, class_name: 'SRDR::KeyQuestion'
end
