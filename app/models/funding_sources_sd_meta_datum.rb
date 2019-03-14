class FundingSourcesSdMetaDatum < ApplicationRecord
  belongs_to :funding_source, inverse_of: :funding_sources_sd_meta_data
  belongs_to :sd_meta_datum, inverse_of: :funding_sources_sd_meta_data
end
