# == Schema Information
#
# Table name: user_project_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  project_id :integer
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

module SRDR
  class UserProjectRole < DbSrdr
  end
end
