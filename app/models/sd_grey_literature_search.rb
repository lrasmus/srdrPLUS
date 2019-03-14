class SdGreyLiteratureSearch < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_grey_literature_searches
end
