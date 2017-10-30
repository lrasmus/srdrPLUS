class ExtractionsExtractionFormsProjectsSection < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction, inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_section
  has_many :type1s, through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy
end
