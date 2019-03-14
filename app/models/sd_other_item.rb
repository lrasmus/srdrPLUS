class SdOtherItem < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_other_items
end
