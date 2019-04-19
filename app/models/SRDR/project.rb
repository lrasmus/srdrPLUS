# == Schema Information
#
# Table name: projects
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  description              :text(65535)
#  notes                    :text(65535)
#  funding_source           :string(510)
#  creator_id               :integer
#  is_public                :boolean          default(FALSE)
#  created_at               :datetime
#  updated_at               :datetime
#  contributors             :text(65535)
#  methodology              :text(65535)
#  prospero_id              :string(255)
#  search_strategy_filepath :string(255)
#  public_downloadable      :boolean          default(FALSE)
#  publication_requested_at :datetime
#  parent_id                :integer
#  attribution              :text(65535)
#  doi_id                   :string(255)
#  management_file_url      :string(255)
#

module SRDR
  class Project < DbSrdr
    has_many :sd_meta_data, inverse_of: :project
    has_many :key_questions, inverse_of: :project

    def prospero_link
      self.prospero_id.present? ?
        "<a href='https://www.crd.york.ac.uk/prospero/display_record.asp?ID=#{self.prospero_id}'>Prospero Link</a>" :
        "Not Available"
    end

    def leading
      SRDR::UserProjectRole.where(role: 'lead', project_id: self.id).map { |upr| SRDR::User.find(upr.user_id) }
    end

    def creator
      SRDR::User.find(SRDR::UserProjectRole.where(project_id: self.id).first.try(:user_id))
    end

    def authors
      SRDR::UserProjectRole.where(project_id: self.id).map { |upr| SRDR::User.find(upr.user_id) }
    end
  end
end
