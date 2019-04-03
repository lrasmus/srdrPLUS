class SdPicod < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_picods
  has_many :sd_key_questions_sd_picods, inverse_of: :sd_picod
  has_many :sd_key_questions, through: :sd_key_questions_sd_picods
  has_many :key_questions, through: :sd_key_questions
end
