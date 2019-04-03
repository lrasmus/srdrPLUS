class SdAnalyticFramework < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_analytic_frameworks
end
