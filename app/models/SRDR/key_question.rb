module SRDR
  class KeyQuestion < DbSrdr
    has_many :sd_key_questions, inverse_of: :key_question, class_name: 'SdKeyQuestion'
    has_many :sd_meta_data, through: :sd_key_questions
    belongs_to :project, inverse_of: :key_questions

  end
end