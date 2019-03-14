class SdSearchStrategy < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_search_strategies
  belongs_to :sd_search_database, inverse_of: :sd_search_strategies
end
