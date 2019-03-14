class SdSummaryOfEvidence < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_summary_of_evidences
  belongs_to :sd_key_question, inverse_of: :sd_summary_of_evidences
end
