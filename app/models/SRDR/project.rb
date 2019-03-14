module SRDR
  class Project < DbSrdr
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