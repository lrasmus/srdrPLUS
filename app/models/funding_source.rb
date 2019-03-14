class FundingSource < ApplicationRecord
  has_many :funding_sources_sd_meta_data, dependent: :destroy, inverse_of: :funding_source
  has_many :sd_meta_data, through: :funding_sources_sd_meta_data, dependent: :destroy

  include SharedQueryableMethods
end
