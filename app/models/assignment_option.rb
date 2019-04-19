# == Schema Information
#
# Table name: assignment_options
#
#  id                        :integer          not null, primary key
#  label_type_id             :integer
#  assignment_id             :integer
#  assignment_option_type_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class AssignmentOption < ApplicationRecord
  belongs_to :label_type, optional: true
  belongs_to :assignment
  belongs_to :assignment_option_type
end
