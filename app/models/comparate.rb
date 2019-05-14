# == Schema Information
#
# Table name: comparates
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  comparate_group_id    :integer
#  comparable_element_id :integer
#  deleted_at            :datetime
#

class Comparate < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparate_group,    inverse_of: :comparates
  belongs_to :comparable_element, inverse_of: :comparates, dependent: :destroy

  accepts_nested_attributes_for :comparable_element, allow_destroy: true
end
