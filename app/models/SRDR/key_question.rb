# == Schema Information
#
# Table name: key_questions
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  question_number :integer
#  question        :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#

module SRDR
  class KeyQuestion < DbSrdr
    has_many :sd_meta_data, through: :sd_key_questions
    belongs_to :project, inverse_of: :key_questions

    has_many :sd_key_questions_projects, inverse_of: :srdr_key_questions, class_name: 'SdKeyQuestionsProject'
    # has_many :sd_key_questions, through: :sd_key_questions_projects

    def sd_key_questions
      SdKeyQuestionsProject.where(key_questions_project_id: self.id).map(&:sd_key_question)
    end
  end
end
