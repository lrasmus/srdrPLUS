class FundingSource < ApplicationRecord
  include SharedQueryableMethods

  has_many :funding_sources_sd_meta_data, inverse_of: :funding_source
  has_many :sd_meta_data, through: :funding_sources_sd_meta_data
end
