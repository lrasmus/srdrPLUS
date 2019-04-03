class SdSearchDatabase < ApplicationRecord
  include SharedQueryableMethods

  has_many :sd_search_strategies, inverse_of: :sd_search_database
  has_many :sd_meta_data, through: :sd_search_strategies
end
