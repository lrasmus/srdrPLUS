# == Schema Information
#
# Table name: labels
#
#  id                     :integer          not null, primary key
#  citations_project_id   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  projects_users_role_id :integer
#  deleted_at             :datetime
#  label_type_id          :integer
#

class Label < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  scope :last_updated, -> ( projects_users_role, offset, count ) { 
                                                where( projects_users_role: projects_users_role )
                                                .order( updated_at: :desc )
                                                .distinct
                                                .offset( offset )
                                                .limit( count ) }  
  belongs_to :citations_project
  belongs_to :projects_users_role
  belongs_to :label_type

  has_many :notes, as: :notable
  has_many :tags, as: :taggable

  has_one :citation, through: :citations_project
  has_one :project, through: :citations_project
  has_one :projects_user, through: :projects_users_role
  has_one :user, through: :projects_users

  has_many :labels_reasons, dependent: :destroy, inverse_of: :label
  has_many :reasons, through: :labels_reasons

  accepts_nested_attributes_for :labels_reasons, allow_destroy: true
end
