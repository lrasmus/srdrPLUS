class SdKeyQuestion < ApplicationRecord
  belongs_to :key_questions_project, inverse_of: :sd_key_questions
  belongs_to :sd_meta_datum, inverse_of: :sd_key_questions

  has_many :sd_key_questions_sd_picods, inverse_of: :sd_key_question
  has_many :sd_picods, through: :sd_key_questions_sd_picods
end
