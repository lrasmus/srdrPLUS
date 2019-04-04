class SdMetaDatum < ApplicationRecord
  include SharedProcessTokenMethods

  default_scope { order(project_id: :asc) }

  belongs_to :project, class_name: 'SRDR::Project', inverse_of: :sd_meta_data

  has_many :sd_key_questions, inverse_of: :sd_meta_datum
  has_many :key_questions, through: :sd_key_questions

  def srdr_key_questions
    SRDR::KeyQuestion.where(project_id: project_id)
  end
  # has_many :sd_key_questions_projects, through: :sd_key_questions
  # has_many :key_questions_projects, through: :sd_key_questions_projects

  has_many :sd_journal_article_urls, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_other_items, inverse_of: :sd_meta_datum, dependent: :destroy

  has_many :sd_search_strategies, inverse_of: :sd_meta_datum
  has_many :sd_search_databases, through: :sd_search_strategies

  has_many :sd_summary_of_evidences, inverse_of: :sd_meta_datum
  has_many :sd_grey_literature_searches, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_prisma_flows, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_picods, inverse_of: :sd_meta_datum
  has_many :sd_analytic_frameworks, inverse_of: :sd_meta_datum, dependent: :destroy

  has_many :funding_sources_sd_meta_data, inverse_of: :sd_meta_datum
  has_many :funding_sources, through: :funding_sources_sd_meta_data

  accepts_nested_attributes_for :sd_key_questions, allow_destroy: true
  accepts_nested_attributes_for :sd_journal_article_urls, allow_destroy: true
  accepts_nested_attributes_for :sd_other_items, allow_destroy: true
  accepts_nested_attributes_for :sd_analytic_frameworks, allow_destroy: true
  accepts_nested_attributes_for :sd_picods, allow_destroy: true
  accepts_nested_attributes_for :sd_search_strategies, allow_destroy: true
  accepts_nested_attributes_for :sd_grey_literature_searches, allow_destroy: true
  accepts_nested_attributes_for :sd_summary_of_evidences, allow_destroy: true
  accepts_nested_attributes_for :sd_prisma_flows, allow_destroy: true

  def s_kqs
    SRDR::KeyQuestion.where(project_id: self.project_id)
  end

  def section_statuses
    (0..5).to_a.map do |i|
      section = 'section_flag_' + i.to_s
      self[section]
    end
  end

  def toggle_state
    new_state = state == 'DRAFT' ? 'COMPLETED' : 'DRAFT'
    update(state: new_state)
  end

  def funding_source_ids=(tokens)
    tokens.map do |token|
      resource = FundingSource.new
      save_resource_name_with_token(resource, token)
    end
    super
  end
end
