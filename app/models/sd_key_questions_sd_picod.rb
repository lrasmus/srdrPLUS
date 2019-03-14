class SdKeyQuestionsSdPicod < ApplicationRecord
  belongs_to :sd_key_question, inverse_of: :sd_key_questions_sd_picods
  belongs_to :sd_picod, inverse_of: :sd_key_questions_sd_picods
end
