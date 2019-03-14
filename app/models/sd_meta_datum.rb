class SdMetaDatum < ApplicationRecord
  include SharedProcessTokenMethods

  belongs_to :project
  has_many :funding_sources_sd_meta_data, dependent: :destroy, inverse_of: :sd_meta_datum
  has_many :funding_sources, through: :funding_sources_sd_meta_data, dependent: :destroy
  has_many :key_questions_projects, through: :sd_key_questions
  has_many :key_question_types, through: :key_questions_projects
  has_many :sd_journal_article_urls, inverse_of: :sd_meta_datum
  has_many :sd_other_items, inverse_of: :sd_meta_datum
  has_many :sd_key_questions, inverse_of: :sd_meta_datum
  has_many :sd_search_strategies, inverse_of: :sd_meta_datum
  has_many :sd_search_databases, through: :sd_search_strategies
  has_many :sd_grey_literature_searches, inverse_of: :sd_meta_datum
  has_many :sd_prisma_flows, inverse_of: :sd_meta_datum
  has_many :sd_picods, inverse_of: :sd_meta_datum
  has_one :sd_analytic_framework, inverse_of: :sd_meta_datum
  accepts_nested_attributes_for :sd_journal_article_urls
  accepts_nested_attributes_for :sd_other_items

  def funding_source_ids=(tokens)
    tokens.map { |token|
      resource = FundingSource.new
      save_resource_name_with_token(resource, token)
    }
    super
  end

  def key_question_type_ids=(tokens)
    tokens.map { |token|
      resource = KeyQuestionType.new
      save_resource_name_with_token(resource, token)
    }
    super
  end
end
