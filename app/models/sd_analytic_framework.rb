class SdAnalyticFramework < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum
end
