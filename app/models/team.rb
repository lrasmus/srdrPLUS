class Team < ApplicationRecord
  belongs_to :team_type
  belongs_to :project

  has_one :coloring, as: :colorable

  has_many :projects_users_roles_teams
  has_many :projects_users_roles, through: :projects_users_roles_teams, dependent: :destroy
end
